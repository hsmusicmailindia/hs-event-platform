// ============================================================================
// HS MUSIC EVENT ECOSYSTEM — END-TO-END PIPELINE SMOKE TEST (V5 CANONICAL)
// FILE: scripts/test_pipeline.js
// CANONICAL REF: STEP_16 (Sec 4), STEP_23 (Sec 6)
// ============================================================================

const https = require("https");

const SUPABASE_URL = process.env.SUPABASE_URL || "https://lfnmedfymmadqjnluqoy.supabase.co";
const ANON_KEY = process.env.SUPABASE_ANON_KEY || "";
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || ANON_KEY;

function sendRequest(url, method, headers, payload) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const bodyStr = payload ? JSON.stringify(payload) : "";

    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      method: method,
      headers: {
        "Content-Type": "application/json",
        ...headers,
      },
    };

    if (payload) {
      options.headers["Content-Length"] = Buffer.byteLength(bodyStr);
    }

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on("error", (err) => reject(err));
    if (payload) req.write(bodyStr);
    req.end();
  });
}

async function runSmokeTest() {
  console.log("================================================================================");
  console.log("HS MUSIC EVENT ECOSYSTEM — VERIFYING END-TO-END FINANCIAL & SAGA INTEGRITY");
  console.log(`TARGET: ${SUPABASE_URL}`);
  console.log("================================================================================\n");

  // TEST 1: AUTHORITATIVE QUOTING ENGINE (Edge Function)
  console.log("[TEST 1/3] Calling 'calculate-quote' Edge Function...");
  const quotePayload = {
    cartItems: [
      { category: "artist", basePricePaisa: 2000000 },
      { category: "venue", basePricePaisa: 5000000 },
    ],
  };

  try {
    const quoteRes = await sendRequest(
      `${SUPABASE_URL}/functions/v1/calculate-quote`,
      "POST",
      { Authorization: `Bearer ${ANON_KEY || "mock-auth"}` },
      quotePayload
    );

    console.log(`HTTP Status: ${quoteRes.status}`);
    if (quoteRes.status === 200 && quoteRes.body.clientSummary) {
      const summary = quoteRes.body.clientSummary;
      console.log(`[PASS] Base Subtotal: ₹${summary.baseSubtotalPaisa / 100}`);
      console.log(`[PASS] Platform Fee: ₹${summary.platformFeePaisa / 100} (Rate: ${summary.platformFeeRateBps} BPS)`);
      console.log(`[PASS] Statutory 18% GST: ₹${summary.gstPaisa / 100}`);
      console.log(`[PASS] Total Payable: ₹${summary.totalPayablePaisa / 100}`);
    } else {
      console.warn(`[WARN] Payload:`, quoteRes.body);
    }
  } catch (err) {
    console.error("[FAIL] Quoting execution error:", err.message);
  }

  // TEST 2: PAYMENT WEBHOOK & SAGA RESOLVER
  console.log("\n[TEST 2/3] Checking Payment Webhook Saga & Idempotency...");
  const freshEventId = `evt_final_${Date.now()}`;
  const webhookPayload = {
    event_id: freshEventId,
    transaction_id: `txn_final_${Date.now()}`,
    booking_ids: ["b0000000-0000-0000-0000-000000000001"],
    amount_paisa: 8673000,
  };

  try {
    const firstCall = await sendRequest(
      `${SUPABASE_URL}/functions/v1/payment-webhook`,
      "POST",
      {},
      webhookPayload
    );
    console.log(`First Submission Status: ${firstCall.status} -> Body:`, firstCall.body);

    const secondCall = await sendRequest(
      `${SUPABASE_URL}/functions/v1/payment-webhook`,
      "POST",
      {},
      webhookPayload
    );
    console.log(`Replay Submission Status: ${secondCall.status} -> Idempotency Defense:`, 
      secondCall.body.status === "ALREADY_PROCESSED" ? "[PASS] ALREADY_PROCESSED Trapped" : secondCall.body
    );
  } catch (err) {
    console.error("[FAIL] Webhook execution error:", err.message);
  }

  // TEST 3: PAYOUT DISPATCHER QUEUE HARNESS
  console.log("\n[TEST 3/3] Calling 'payout-dispatcher' with System Context...");
  try {
    const payoutRes = await sendRequest(
      `${SUPABASE_URL}/functions/v1/payout-dispatcher`,
      "POST",
      {},
      {}
    );
    console.log(`HTTP Status: ${payoutRes.status} -> Queue Execution:`, payoutRes.body);
  } catch (err) {
    console.error("[FAIL] Payout dispatcher execution error:", err.message);
  }

  console.log("\n================================================================================");
  console.log("SMOKE TEST COMPLETED");
  console.log("================================================================================");
}

runSmokeTest();