-- Cole tudo isto no Supabase: SQL Editor > New query > Run
create table if not exists proposals(
  id uuid primary key default gen_random_uuid(),
  owner uuid not null default auth.uid() references auth.users(id) on delete cascade,
  public_id text unique not null default replace(gen_random_uuid()::text,'-',''),
  title text, client text,
  data jsonb not null,
  views int not null default 0,
  last_viewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table proposals enable row level security;
create policy "dono acessa suas propostas" on proposals for all to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());

-- o cliente (sem login) só consegue abrir UMA proposta, pelo código do link
create or replace function get_proposal(pid text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  update proposals set views = views + 1, last_viewed_at = now()
  where public_id = pid returning data into r;
  return r;
end $$;
revoke all on function get_proposal(text) from public;
grant execute on function get_proposal(text) to anon, authenticated;
