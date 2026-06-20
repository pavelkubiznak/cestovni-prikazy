-- ============================================================
-- Cestovní příkazy SINTERA — Supabase setup (SDÍLENÝ TÝMOVÝ MODEL)
-- Spustit jednou v SQL Editoru projektu cestovni-prikazy (tgwlzmrdirqrqtqgprod).
--
-- Jedna společná sada dat pro celý tým: každý přihlášený uživatel vidí a
-- upravuje stejné řidiče / cesty / výjimky / historii. Přístup se omezuje
-- tím, že vypnete veřejné registrace (Authentication → Providers → Email →
-- "Allow new users to sign up" OFF) — účet má jen ten, koho pustíte dovnitř.
-- ============================================================

create table if not exists public.cp_shared (
  id         text primary key,
  nastaveni  jsonb not null default '{}'::jsonb,
  vyjimky    jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- jediný sdílený řádek
insert into public.cp_shared (id) values ('main') on conflict (id) do nothing;

alter table public.cp_shared enable row level security;

-- Každý přihlášený (authenticated) uživatel má plný přístup ke sdíleným datům.
drop policy if exists "cp_shared_rw" on public.cp_shared;
create policy "cp_shared_rw" on public.cp_shared
  for all to authenticated
  using (true) with check (true);
