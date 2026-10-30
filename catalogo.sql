-- Cole no Supabase: SQL Editor > New query > Run
create table if not exists catalog(
  owner uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table catalog enable row level security;
create policy "dono acessa seu catalogo" on catalog for all to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());
