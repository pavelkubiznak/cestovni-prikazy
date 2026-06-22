// Supabase connection — publishable (public) key is safe to ship in a client app.
// Data is protected by Row Level Security: each user only sees their own row.
window.__SB = {
  url: "https://tgwlzmrdirqrqtqgprod.supabase.co",
  anon: "sb_publishable_JqSGar-QkP6OC02bkZNQNw_1b0B1wpo",
  // n8n webhook pro odeslání e-mailu účetní (přes vlastní SMTP sintera.cz).
  // Doplň produkční URL z n8n po importu a aktivaci workflow:
  n8nMail: ""
};
