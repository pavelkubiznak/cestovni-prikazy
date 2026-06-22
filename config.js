// Supabase connection — publishable (public) key is safe to ship in a client app.
// Data is protected by Row Level Security: each user only sees their own row.
window.__SB = {
  url: "https://tgwlzmrdirqrqtqgprod.supabase.co",
  anon: "sb_publishable_JqSGar-QkP6OC02bkZNQNw_1b0B1wpo",
  // Režim odesílání e-mailu účetní:
  //   ""     = bez backendu → stáhne ZIP s PDF + otevře e-mail (přílohu přidá uživatel)
  //   "edge" = jeden klik přes Supabase funkci send-prikazy (potřebuje nastaveného providera)
  //   "n8n"  = přes vlastní n8n webhook (n8nMail níže)
  sendMode: "",
  // n8n webhook (jen když sendMode="n8n"):
  n8nMail: ""
};
