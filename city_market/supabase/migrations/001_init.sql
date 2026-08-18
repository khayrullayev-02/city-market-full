-- =============================================================
-- City Market — Supabase schema (MVP)
-- Supabase Dashboard > SQL Editor da ishga tushiring.
-- =============================================================

-- 1) Profillar (auth.users bilan bog'lanadi)
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  phone text unique,
  full_name text,
  created_at timestamptz default now()
);

-- 2) Kategoriyalar (oziq-ovqat / uy-ro'zg'or)
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name jsonb not null default '{"uz":"","ru":"","en":""}', -- {uz, ru, en}
  emoji text default '🛒',
  is_household boolean default false,
  "order" int default 0
);

-- 3) Mahsulotlar — to'liq (kengaytirilgan) ma'lumotlar
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories on delete set null,
  name jsonb not null default '{"uz":"","ru":"","en":""}',
  description jsonb not null default '{"uz":"","ru":"","en":""}',
  brand text default '',
  sku text,
  price numeric(12,2) not null default 0,
  old_price numeric(12,2),            -- chegirma uchun eski narx
  unit text not null default 'dona',  -- kg | litr | dona | g | ml
  unit_value numeric default 1,       -- 1, 0.5, 10...
  stock int not null default 0,
  min_stock int default 5,            -- kam qoldiq ogohlantirishi
  images text[] default '{}',         -- Storage URL lar ro'yxati
  video_url text,                     -- MP4 havolasi
  tags text[] default '{}',
  country_origin text default '',
  manufacturer text default '',
  weight_kg numeric,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 4) Manzillar
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles on delete cascade,
  label text default 'home',          -- home | work | other
  city text default '',
  address text not null,
  is_default boolean default false
);

-- 5) Sevimlilar
create table if not exists public.favorites (
  user_id uuid references public.profiles on delete cascade,
  product_id uuid references public.products on delete cascade,
  primary key (user_id, product_id)
);

-- 6) Buyurtmalar
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  number text unique,
  user_id uuid references public.profiles on delete set null,
  address_text text default '',
  delivery_slot text default '',
  payment_method text default 'cash', -- cash | payme | click
  payment_status text default 'pending',
  comment text default '',
  subtotal numeric(12,2) default 0,
  delivery_fee numeric(12,2) default 0,
  total numeric(12,2) default 0,
  status text default 'accepted',     -- accepted | preparing | onway | delivered | cancelled
  created_at timestamptz default now()
);

-- 7) Buyurtma qatorlari
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders on delete cascade,
  product_id uuid references public.products on delete set null,
  name text default '',
  price numeric(12,2) default 0,
  qty int default 1,
  unit text default ''
);

-- =============================================================
-- Row Level Security (asosiy qoidalar)
-- =============================================================
alter table public.profiles    enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;
alter table public.addresses   enable row level security;
alter table public.favorites   enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

-- Ommaviy o'qish (katalog)
create policy "categories read" on public.categories for select using (true);
create policy "products read"   on public.products   for select using (true);

-- Foydalanuvchi o'z ma'lumotlarini o'qiydi/yozadi
create policy "profiles own" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "addresses own" on public.addresses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "favorites own" on public.favorites
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "orders own" on public.orders
  for select using (auth.uid() = user_id);

create policy "orders insert" on public.orders
  for insert with check (auth.uid() = user_id or user_id is null);

-- =============================================================
-- Storage bucket (mahsulot rasmlari)
-- =============================================================
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do nothing;

create policy "products images public read" on storage.objects
  for select using (bucket_id = 'products');

-- =============================================================
-- Realtime: buyurtma statusi o'zgarganda mijozga jonli xabar
-- =============================================================
alter publication supabase_realtime add table public.orders;
alter publication supabase_realtime add table public.products;
