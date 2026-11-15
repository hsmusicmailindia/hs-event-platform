import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, idempotency-key",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

Deno.serve(async (req: Request) => {
  // 1. Handle CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // 2. Validate Idempotency-Key Header (STEP_11 / STEP_17)
    const idempotencyKey = req.headers.get("Idempotency-Key")
    if (!idempotencyKey) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_MISSING_IDEMPOTENCY_KEY",
            message: "Idempotency-Key header is strictly required for checkout intent.",
          }
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // 3. Extract User JWT for Impersonation Protocol (STEP_10 / STEP_11)
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_UNAUTHORIZED",
            message: "Missing Authorization Bearer token.",
          }
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // 4. Parse Request Payload
    const body = await req.json()
    const { event_package_id, expected_total_paisa } = body

    if (!event_package_id || expected_total_paisa === undefined) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_INVALID_PAYLOAD",
            message: "Both event_package_id and expected_total_paisa are required.",
          }
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // 5. Initialize Supabase Client under User Context (RLS Enforced)
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "http://host.docker.internal:54321"
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? ""

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } }
    })

    // Verify authenticated user identity via GoTrue
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({
          error: {
            code: "ERR_INVALID_TOKEN",
            message: "User context could not be verified from token.",
            details: userError?.message
          }
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    // 6. Generate Gateway Intent Response (Phase 5 Canonical Contract)
    const intentPayload = {
      status: "AWAITING_PAYMENT_HOLD",
      client_id: user.id,
      event_package_id: event_package_id,
      expected_total_paisa: Number(expected_total_paisa),
      currency: "INR",
      idempotency_key: idempotencyKey,
      hold_expires_at: new Date(Date.now() + 15 * 60 * 1000).toISOString(),
      gateway_intent_token: `mock_pi_${crypto.randomUUID().replace(/-/g, "").slice(0, 16)}`
    }

    return new Response(
      JSON.stringify(intentPayload),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )

  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : "Internal Server Error"
    return new Response(
      JSON.stringify({
        error: {
          code: "ERR_CHECKOUT_INTENT_FAILED",
          message: errorMsg,
        }
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  }
})