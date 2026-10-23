-- Crave & Bite schema (already applied to the project). Re-run only on a fresh Supabase project.
create table public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.admins enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;
create policy "admin reads own row" on public.admins for select to authenticated using (user_id = auth.uid());

create table public.categories (id bigint generated always as identity primary key, name text not null unique check (char_length(name) between 1 and 40), sort int not null default 0);
create table public.menu_items (id uuid primary key default gen_random_uuid(), category_id bigint not null references public.categories(id) on delete restrict,
  name text not null check (char_length(name) between 1 and 80), description text check (description is null or char_length(description) <= 300),
  prices integer[] not null check (cardinality(prices) between 1 and 4 and 0 < all(prices) and 100000 > all(prices)),
  spicy boolean not null default false, available boolean not null default true, featured boolean not null default false, published boolean not null default true,
  image_url text, sort int not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.combos (id uuid primary key default gen_random_uuid(), title text not null check (char_length(title) between 1 and 80), items text[] not null,
  original_price integer not null check (original_price > 0), price integer not null check (price > 0), image_keys text[], image_url text, active boolean not null default true, sort int not null default 0);
create table public.offers (id uuid primary key default gen_random_uuid(), title text not null check (char_length(title) between 1 and 80), description text check (description is null or char_length(description) <= 300),
  image_url text, discount_type text not null default 'none' check (discount_type in ('none','percentage','fixed','special_price')), discount_value integer check (discount_value is null or discount_value > 0),
  applies_to text, promo_code text check (promo_code is null or char_length(promo_code) <= 30), cta_text text not null default 'Order Now' check (char_length(cta_text) <= 30),
  cta_link text not null default '#offers' check (cta_link ~ '^(#|/|https://)'), start_at timestamptz, end_at timestamptz, active boolean not null default true, published boolean not null default false,
  created_at timestamptz not null default now(), check (end_at is null or start_at is null or end_at > start_at));
create table public.site_settings (id int primary key default 1 check (id = 1), popup_enabled boolean not null default true, popup_offer_id uuid references public.offers(id) on delete set null,
  delivery_enabled boolean not null default false, delivery_charge integer check (delivery_charge is null or delivery_charge >= 0), updated_at timestamptz not null default now());

alter table public.categories enable row level security; alter table public.menu_items enable row level security; alter table public.combos enable row level security;
alter table public.offers enable row level security; alter table public.site_settings enable row level security;
create policy "public read categories" on public.categories for select using (true);
create policy "public read items" on public.menu_items for select using (published or public.is_admin());
create policy "public read combos" on public.combos for select using (active or public.is_admin());
create policy "public read live offers" on public.offers for select using (public.is_admin() or (published and active and (start_at is null or start_at <= now()) and (end_at is null or end_at >= now())));
create policy "public read settings" on public.site_settings for select using (true);
create policy "admin write categories" on public.categories for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write items" on public.menu_items for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write combos" on public.combos for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write offers" on public.offers for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write settings" on public.site_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values ('media','media',true,3145728, array['image/jpeg','image/png','image/webp']) on conflict (id) do nothing;
create policy "public read media" on storage.objects for select using (bucket_id = 'media');
create policy "admin insert media" on storage.objects for insert to authenticated with check (bucket_id = 'media' and public.is_admin());
create policy "admin update media" on storage.objects for update to authenticated using (bucket_id = 'media' and public.is_admin()) with check (bucket_id = 'media' and public.is_admin());
create policy "admin delete media" on storage.objects for delete to authenticated using (bucket_id = 'media' and public.is_admin());
-- First admin (run AFTER creating the user in Supabase Auth): 
-- insert into public.admins (user_id) select id from auth.users where email = 'OWNER_EMAIL_HERE';
