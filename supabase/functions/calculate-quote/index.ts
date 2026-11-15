// ============================================================================
// HS EVENT PLATFORM — AUTHORITATIVE QUOTING ENGINE
// FILE: supabase/functions/calculate-quote/index.ts
// CANONICAL REF: STEP_04 (Sec 3.3), STEP_11 (Sec 3), STEP_17 (Sec 7.1)
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, idempotency-key",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// BigInt Banker's Rounding helper: (val + 5000n) / 10000n
const roundBigIntBps = (amountPaisa: bigint, bps: bigint): bigint => {
  return (amountPaisa * bps + 5000n) / 10000n;
};

interface CartItemInput {
  serviceId?: string;
  category: string;
  basePricePaisa: number | string;
}

interface QuoteRequestPayload {
  eventPackageId?: string;
  cartItems: CartItemInput[];
}

/**
 * Resolves Provider Facilitation Fee BPS (Seller Commission)
 * Venue: Flat 5% (500 BPS)
 * Artist 4-Tier Ladder:
 *   - Below ₹15,000       -> 20% (2000 BPS)
 *   - ₹15,000 to <₹25,000 -> 15% (1500 BPS)
 *   - ₹25,000 to <₹50,000 -> 10% (1000 BPS)
 *   - ₹50,000 and above   -> 5%  (500 BPS)
 */
export function resolveProviderFacilitationBps(category: string, basePricePaisa: bigint): bigint {
  const normCat = category.toLowerCase().trim();

  // Rule 1: Venues are flat 5% (500 BPS)
  if (normCat === "venue" || normCat === "banquet" || normCat === "hall") {
    return 500n;
  }

  // Rule 2: Artist 4-Tier Ladder
  const artistCategories = ["artist", "singer", "guitarist", "band", "musician", "dj", "performer"];
  if (artistCategories.includes(normCat)) {
    if (basePricePaisa < 1500000n) {
      return 2000n; // 20% (< 15k)
    }
    if (basePricePaisa < 2500000n) {
      return 1500n; // 15% (15k - 25k)
    }
    if (basePricePaisa < 5000000n) {
      return 1000n; // 10% (25k - 50k)
    }
    return 500n;    // 5% (>= 50k)
  }

  // Fallback for general categories
  return basePricePaisa >= 5000000n ? 500n : 1000n;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_UNAUTHORIZED",
            http_status: 401,
            message: "Missing Authorization Bearer token.",
          },
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const payload: QuoteRequestPayload = await req.json();

    if (!payload.cartItems || !Array.isArray(payload.cartItems) || payload.cartItems.length === 0) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_EMPTY_CART",
            http_status: 400,
            message: "Payload must contain a non-empty cartItems array.",
          },
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Client Fee: Flat 5% (500 BPS)
    const CLIENT_PLATFORM_FEE_BPS = 500n;
    // Statutory GST: 18% (1800 BPS)
    const STATUTORY_GST_BPS = 1800n;
    // Statutory TDS: 1% (100 BPS under Sec 194-O)
    const STATUTORY_TDS_BPS = 100n;

    let aggregateBasePaisa = 0n;
    let aggregateFacilitationFeePaisa = 0n;
    let aggregateTdsPaisa = 0n;

    const lineItemSnapshots = payload.cartItems.map((item) => {
      const basePricePaisa = BigInt(item.basePricePaisa);
      aggregateBasePaisa += basePricePaisa;

      // Provider Facilitation Math
      const facilitationBps = resolveProviderFacilitationBps(item.category, basePricePaisa);
      const facilitationFeePaisa = roundBigIntBps(basePricePaisa, facilitationBps);
      const tdsPaisa = roundBigIntBps(basePricePaisa, STATUTORY_TDS_BPS);
      const netPayoutPaisa = basePricePaisa - facilitationFeePaisa - tdsPaisa;

      aggregateFacilitationFeePaisa += facilitationFeePaisa;
      aggregateTdsPaisa += tdsPaisa;

      return {
        serviceId: item.serviceId ?? null,
        category: item.category,
        basePricePaisa: Number(basePricePaisa),
        facilitationFeeRateBps: Number(facilitationBps),
        facilitationFeePaisa: Number(facilitationFeePaisa),
        tdsPaisa: Number(tdsPaisa),
        netPayoutPaisa: Number(netPayoutPaisa),
      };
    });

    // 1. Client Payables Math (Aggregate Level to eliminate fractional penny drift)
    const clientPlatformFeePaisa = roundBigIntBps(aggregateBasePaisa, CLIENT_PLATFORM_FEE_BPS);
    const clientGstPaisa = roundBigIntBps(aggregateBasePaisa + clientPlatformFeePaisa, STATUTORY_GST_BPS);
    const totalPayableByClientPaisa = aggregateBasePaisa + clientPlatformFeePaisa + clientGstPaisa;

    // 2. Platform Escrow & Ledger Totals
    const providerNetSettlementTotalPaisa = aggregateBasePaisa - aggregateFacilitationFeePaisa - aggregateTdsPaisa;
    const totalPlatformRevenuePaisa = clientPlatformFeePaisa + aggregateFacilitationFeePaisa;

    const responseData = {
      eventPackageId: payload.eventPackageId ?? null,
      currency: "INR",
      clientSummary: {
        baseSubtotalPaisa: Number(aggregateBasePaisa),
        platformFeeRateBps: Number(CLIENT_PLATFORM_FEE_BPS),
        platformFeePaisa: Number(clientPlatformFeePaisa),
        gstRateBps: Number(STATUTORY_GST_BPS),
        gstPaisa: Number(clientGstPaisa),
        totalPayablePaisa: Number(totalPayableByClientPaisa),
      },
      providerSettlementSummary: {
        grossBasePaisa: Number(aggregateBasePaisa),
        totalFacilitationFeePaisa: Number(aggregateFacilitationFeePaisa),
        totalTdsPaisa: Number(aggregateTdsPaisa),
        netPayoutPaisa: Number(providerNetSettlementTotalPaisa),
      },
      platformRevenueSummary: {
        clientFeePaisa: Number(clientPlatformFeePaisa),
        facilitationFeePaisa: Number(aggregateFacilitationFeePaisa),
        grossPlatformRevenuePaisa: Number(totalPlatformRevenuePaisa),
      },
      lineItems: lineItemSnapshots,
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : "Internal Server Error";
    return new Response(
      JSON.stringify({
        error: {
          code: "ERR_QUOTE_CALCULATION_FAILED",
          http_status: 500,
          message: errorMsg,
        },
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});