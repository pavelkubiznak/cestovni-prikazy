// Supabase Edge Function: send-prikazy
// Odešle e-mail s PDF přílohami cestovních příkazů přes Resend.
// Tajný RESEND_API_KEY je uložen jako secret (není v klientovi).
// Volat smí jen přihlášený uživatel (ověřuje se access token).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Použij POST" }, 405);

  try {
    // 1) Ověř, že volá přihlášený uživatel
    const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "").trim();
    if (!token) return json({ error: "Chybí přihlášení." }, 401);
    const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { Authorization: `Bearer ${token}`, apikey: SUPABASE_ANON_KEY },
    });
    if (!who.ok) return json({ error: "Neplatné přihlášení." }, 401);

    // 2) Vstup
    const { from, to, cc, subject, html, attachments } = await req.json();
    const recipients = (Array.isArray(to) ? to : [to]).filter(Boolean);
    if (!recipients.length) return json({ error: "Chybí příjemci." }, 400);
    if (!Array.isArray(attachments) || !attachments.length) {
      return json({ error: "Chybí přílohy (PDF)." }, 400);
    }
    if (!RESEND_API_KEY) return json({ error: "Chybí RESEND_API_KEY (secret)." }, 500);

    // 3) Odeslání přes Resend
    const r = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        from: from || "Cestovní příkazy <onboarding@resend.dev>",
        to: recipients,
        cc: cc && cc.length ? cc : undefined,
        subject: subject || "Cestovní příkazy",
        html: html || "<p>Cestovní příkazy v příloze.</p>",
        attachments: attachments.map((a: { filename: string; content: string }) => ({
          filename: a.filename,
          content: a.content, // base64
        })),
      }),
    });
    const out = await r.json().catch(() => ({}));
    if (!r.ok) return json({ error: out?.message || "Chyba odeslání (Resend).", detail: out }, 502);
    return json({ ok: true, id: out?.id });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
