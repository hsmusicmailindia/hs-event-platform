// ============================================================================
// HS EVENT PLATFORM — GATEWAY WEBHOOK & SAGA RESOLVER
// FILE: supabase/functions/payment-webhook/index.ts
// CANONICAL REF: STEP_04 (Sec 3.1), STEP_11 (Sec 4.2), STEP_17 (Sec 8)
// ============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, stripe-signature, x-razorpay-signature",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const rawBody = await req.text();
    const payload = JSON.parse(rawBody);

    // 1. Idempotency Assertion (72-hour protection)
    const eventId = payload.event_id || payload.id || `evt_${Date.now()}`;
    const { error: idempError } = await supabase
      .from("idempotency_keys")
      .insert([{ key: eventId, created_at: new Date().toISOString() }]);

    if (idempError && idempError.code === "23505") {
      return new Response(JSON.stringify({ status: "ALREADY_PROCESSED" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // 2. Extract Gateway Payload Parameters
    const gatewayTxnId = payload.transaction_id || payload.data?.object?.id || `txn_${Date.now()}`;
    let bookingIds: string[] = payload.booking_ids || (payload.metadata?.booking_ids ? JSON.parse(payload.metadata.booking_ids) : []);
    const totalAmountPaisa = BigInt(payload.amount_paisa || payload.data?.object?.amount || 0);
    const packageId = payload.package_id || payload.metadata?.package_id || null;

    // Cart-level fallback: If bookingIds is empty but packageId exists, resolve child bookings
    if (bookingIds.length === 0 && packageId) {
      const { data: pkgBookings } = await supabase
        .from("bookings")
        .select("id")
        .eq("event_package_id", packageId);
      if (pkgBookings && pkgBookings.length > 0) {
        bookingIds = pkgBookings.map((b: { id: string }) => b.id);
      }
    }

    if (bookingIds.length === 0 || totalAmountPaisa <= 0n) {
      return new Response(JSON.stringify({ error: "Invalid booking payload" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 3. Strict Polymorphic XOR Sanitization:
    // If booking-level IDs are being settled, package_id MUST be null to satisfy DB constraint chk_polymorphic_payment_target
    const targetPackageId = bookingIds.length > 0 ? null : packageId;

    // 4. Delegate to Authoritative Database Transaction Engine
    const { data: rpcResult, error: rpcError } = await supabase.rpc("rpc_confirm_gateway_payment", {
      p_gateway_txn_id: gatewayTxnId,
      p_booking_ids: bookingIds,
      p_total_amount_paisa: totalAmountPaisa.toString(),
      p_package_id: targetPackageId,
    });

    if (rpcError) {
      console.error("RPC Saga Failure:", rpcError);
      return new Response(JSON.stringify({ error: rpcError.message }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      });
    }

    return new Response(JSON.stringify({ success: true, result: rpcResult }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err: any) {
    console.error("Webhook processing error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});