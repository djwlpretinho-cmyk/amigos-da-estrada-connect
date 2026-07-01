-- Amigos da Estrada Connect v6.2.1 — Supabase FINAL

-- Amigos da Estrada Connect v6.1.15 — Supabase Storage + tabelas flexíveis
-- Rode no Supabase SQL Editor. Depois, no Storage, confirme que o bucket site-assets está público.
create table if not exists public.app_state (
  key text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz default now()
);
create table if not exists public.gallery (id bigint, title text, description text, img text, video text, author text, created_at text);
create table if not exists public.videos (id bigint, title text, channel text, link text, thumb text, created_at text);
create table if not exists public.downloads (id bigint, title text, description text, link text, img text, cat text, downloads int default 0, created_at text);
create table if not exists public.news (id bigint, title text, body text, img text, created_at text);
create table if not exists public.members (id bigint, driver_id text, nick text, email text, password text, role text, level int, status text, city text, created_at text, points int default 0, km_total int default 0, wallet_points int default 100, deliveries int default 0, comboios int default 0, infractions int default 0, driver_status text default 'Ativo');
create table if not exists public.gifts (id bigint, member_email text, member_name text, title text, link text, created_at text);
create table if not exists public.mrh_presets (id bigint, title text, description text, img text, link text, created_at text);
create table if not exists public.activities (id bigint, email text, nick text, type text, body text, points int default 0, km int default 0, created_at text);
create table if not exists public.deliveries (id bigint, member text, nick text, type text, status text, km int default 0, file text, created_at text);

alter table public.app_state enable row level security;
alter table public.gallery enable row level security;
alter table public.videos enable row level security;
alter table public.downloads enable row level security;
alter table public.news enable row level security;
alter table public.members enable row level security;
alter table public.gifts enable row level security;
alter table public.mrh_presets enable row level security;
alter table public.activities enable row level security;
alter table public.deliveries enable row level security;

-- Políticas temporárias para lançamento/teste público. Depois podemos restringir escrita ao ADM.
do $$
declare t text;
begin
  foreach t in array array['app_state','gallery','videos','downloads','news','members','gifts','mrh_presets','activities','deliveries'] loop
    execute format('drop policy if exists "aec read %s" on public.%I', t, t);
    execute format('create policy "aec read %s" on public.%I for select to anon, authenticated using (true)', t, t);
    execute format('drop policy if exists "aec insert %s" on public.%I', t, t);
    execute format('create policy "aec insert %s" on public.%I for insert to anon, authenticated with check (true)', t, t);
    execute format('drop policy if exists "aec update %s" on public.%I', t, t);
    execute format('create policy "aec update %s" on public.%I for update to anon, authenticated using (true) with check (true)', t, t);
  end loop;
end $$;

insert into storage.buckets (id, name, public)
values ('site-assets', 'site-assets', true)
on conflict (id) do update set public = true;

drop policy if exists "public read site assets" on storage.objects;
create policy "public read site assets" on storage.objects
for select to anon, authenticated using (bucket_id = 'site-assets');

drop policy if exists "public upload site assets" on storage.objects;
create policy "public upload site assets" on storage.objects
for insert to anon, authenticated with check (bucket_id = 'site-assets');

drop policy if exists "public update site assets" on storage.objects;
create policy "public update site assets" on storage.objects
for update to anon, authenticated using (bucket_id = 'site-assets') with check (bucket_id = 'site-assets');
