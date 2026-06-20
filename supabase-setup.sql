-- ============================================================
-- Cestovní příkazy SINTERA — Supabase setup
-- SDÍLENÝ TÝMOVÝ MODEL + bezpečná souběžnost (Realtime + optimistický zámek)
-- Spustit jednou v SQL Editoru projektu cestovni-prikazy (tgwlzmrdirqrqtqgprod).
--
-- Přístup se omezuje vypnutím veřejných registrací
-- (Authentication → Providers → Email → "Allow new users to sign up" OFF).
-- ============================================================

-- 1) Sdílená nastavení + řidiči + výjimky (jeden řádek pro celý tým)
create table if not exists public.cp_shared (
  id         text primary key,
  nastaveni  jsonb not null default '{}'::jsonb,
  vyjimky    jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
insert into public.cp_shared (id) values ('main') on conflict (id) do nothing;
alter table public.cp_shared enable row level security;
drop policy if exists "cp_shared_rw" on public.cp_shared;
create policy "cp_shared_rw" on public.cp_shared
  for all to authenticated using (true) with check (true);

-- 2) Historie příkazů (jeden řádek na snímek → souběžné zápisy se nikdy nepoperou)
create table if not exists public.cp_historie (
  id        text primary key,           -- 'ridic|RRRR-MM'
  ridic     text not null,
  mk        text not null,
  obdobi    text,
  data      jsonb not null default '{}'::jsonb,
  vytvoreno timestamptz not null default now()
);
alter table public.cp_historie enable row level security;
drop policy if exists "cp_historie_rw" on public.cp_historie;
create policy "cp_historie_rw" on public.cp_historie
  for all to authenticated using (true) with check (true);

-- 3) Živá synchronizace (Realtime) — změny se objeví všem hned
do $$ begin alter publication supabase_realtime add table public.cp_shared;    exception when others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.cp_historie;  exception when others then null; end $$;
