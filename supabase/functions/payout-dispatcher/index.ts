// ============================================================================
// HS EVENT PLATFORM — OUTBOUND PAYOUT & REFUND DISPATCHER
// FILE: supabase/functions/payout-dispatcher/index.ts
// CANONICAL REF: STEP_09 (Sec 5.6), STEP_11 (Sec 5), STEP_17 (Sec 7/8)
// ============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Missing Supabase system credentials in environment.");
    }

    // System execution: Uses service_role to manage internal financial queues
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    });

    // 1. Fetch pending payout records (Batch limit: 20 items per run)
    const { data: pendingPayouts, error: fetchError } = await supabase
      .from("outbound_refunds")
      .select("id, booking_id, amount_paisa, type, retry_count")
      .eq("status", "pending_payout")
      .lt("retry_count", 3)
      .limit(20);

    if (fetchError) {
      console.error("Queue Fetch Error:", fetchError);
      return new Response(JSON.stringify({ error: fetchError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!pendingPayouts || pendingPayouts.length === 0) {
      return new Response(JSON.stringify({ processed: 0, message: "No pending payouts in queue" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    let processedCount = 0;

    // 2. Process each queued payout atomically
    for (const payout of pendingPayouts) {
      // Mark as processing_payout
      await supabase
        .from("outbound_refunds")
        .update({ status: "processing_payout", updated_at: new Date().toISOString() })
        .eq("id", payout.id);

      try {
        // Mock Gateway Transfer ID (In production, replace with actual RazorpayX/Stripe Connect API call)
        const payoutTransferId = `payout_tx_${Date.now()}_${payout.id.substring(0, 8)}`;

        // Transition Escrow Ledger to paid_out and attach trace ID
        if (payout.booking_id) {
          await supabase
            .from("escrow_ledgers")
            .update({
              escrow_state: "paid_out",
              payout_transfer_id: payoutTransferId,
              updated_at: new Date().toISOString(),
            })
            .eq("booking_id", payout.booking_id);
        }

        // Mark queue row as completed
        await supabase
          .from("outbound_refunds")
          .update({
            status: "completed",
            gateway_transaction_id: payoutTransferId,
            updated_at: new Date().toISOString(),
          })
          .eq("id", payout.id);

        processedCount++;
      } catch (txnError: any) {
        console.error(`Payout failure for ID ${payout.id}:`, txnError);
        // Increment retry count; mark failed if retry limit hit
        const nextRetry = (payout.retry_count || 0) + 1;
        await supabase
          .from("outbound_refunds")
          .update({
            status: nextRetry >= 3 ? "failed" : "pending_payout",
            retry_count: nextRetry,
            updated_at: new Date().toISOString(),
          })
          .eq("id", payout.id);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        processed_count: processedCount,
        batch_total: pendingPayouts.length,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("Payout Dispatcher Fatal Error:", err);
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});