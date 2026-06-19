-- ============================================================
-- Cestovní příkazy SINTERA — Supabase setup
-- Run once in the Supabase SQL Editor (project fpknbrzbqpalguajskut).
-- Creates an isolated, namespaced table with strict Row Level Security
-- so every user can only read/write their OWN row. Does not touch any
-- existing tables.
-- ============================================================

create table if not exists public.cestovni_prikazy_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  nastaveni  jsonb not null default '{}'::jsonb,
  vyjimky    jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.cestovni_prikazy_data enable row level security;

-- Each authenticated user may only see and modify their own row.
drop policy if exists "cp_select_own" on public.cestovni_prikazy_data;
create policy "cp_select_own" on public.cestovni_prikazy_data
  for select using (auth.uid() = user_id);

drop policy if exists "cp_insert_own" on public.cestovni_prikazy_data;
create policy "cp_insert_own" on public.cestovni_prikazy_data
  for insert with check (auth.uid() = user_id);

drop policy if exists "cp_update_own" on public.cestovni_prikazy_data;
create policy "cp_update_own" on public.cestovni_prikazy_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cp_delete_own" on public.cestovni_prikazy_data;
create policy "cp_delete_own" on public.cestovni_prikazy_data
  for delete using (auth.uid() = user_id);
