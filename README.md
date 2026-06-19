# Cestovní příkazy SINTERA

Online aplikace pro generování a evidenci cestovních příkazů (SINTERA Czech s.r.o.).
Přihlášení e‑mailem a heslem, data se synchronizují přes Supabase mezi všemi zařízeními
(notebook i mobil).

## Architektura
- **Frontend:** jeden statický `index.html` (žádný build), hostovaný na GitHub Pages.
- **Auth + databáze:** Supabase (projekt `fpknbrzbqpalguajskut`).
  - Přihlášení: Supabase Auth (e‑mail + heslo).
  - Data: tabulka `cestovni_prikazy_data` (jeden řádek na uživatele) chráněná Row Level Security.
- **Konfigurace:** `config.js` obsahuje URL projektu a veřejný `anon` klíč
  (anon klíč je určen pro klientské aplikace; přístup k datům hlídá RLS).

## Soukromí
Jména řidičů, adresy a SPZ **nejsou** ve veřejném repozitáři. Žijí pouze v přihlášeném
cloud účtu uživatele. Lokální soubor `seed.local.json` (mimo git) sloužil k prvotnímu
naplnění účtu.

## Nasazení / setup
1. V Supabase SQL editoru spustit `supabase-setup.sql` (vytvoří tabulku + RLS).
2. Do `config.js` doplnit `anon` klíč projektu (Settings → API → Project API keys → `anon public`).
3. Commit + push; GitHub Pages naservíruje `index.html`.

## Lokální spuštění
```
python3 -m http.server 8000
# http://localhost:8000
```
