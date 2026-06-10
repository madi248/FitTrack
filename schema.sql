-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ==========================================
-- 1. TABLES & POLICIES
-- ==========================================

-- PROFILES TABLE
create table if not exists public.profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  name text,
  age integer,
  height numeric,
  weight numeric,
  gender text,
  activity_level text,
  avatar_url text, -- Added from update_schema
  
  constraint username_length check (char_length(name) >= 3)
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile." on profiles for select using (auth.uid() = id);
create policy "Users can insert their own profile." on profiles for insert with check (auth.uid() = id);
create policy "Users can update their own profile." on profiles for update using (auth.uid() = id);


-- DAILY GOALS TABLE
create table if not exists public.daily_goals (
  user_id uuid references auth.users not null,
  calories integer default 2000,
  calories_to_burn integer default 500,
  protein integer default 150,
  carbs integer default 200,
  fat integer default 67,
  updated_at timestamp with time zone,
  
  primary key (user_id)
);

alter table public.daily_goals enable row level security;

create policy "Users can view their own goals." on daily_goals for select using (auth.uid() = user_id);
create policy "Users can insert/update their own goals." on daily_goals for all using (auth.uid() = user_id);


-- MEALS TABLE
create table if not exists public.meals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  date text not null, -- Format YYYY-MM-DD
  breakfast jsonb default '[]'::jsonb,
  lunch jsonb default '[]'::jsonb,
  dinner jsonb default '[]'::jsonb,
  updated_at timestamp with time zone,
  
  unique(user_id, date)
);

alter table public.meals enable row level security;

create policy "Users can view their own meals." on meals for select using (auth.uid() = user_id);
create policy "Users can insert/update their own meals." on meals for all using (auth.uid() = user_id);


-- ACTIVITIES TABLE
create table if not exists public.activities (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  date text not null,
  activities jsonb default '[]'::jsonb,
  updated_at timestamp with time zone,
  
  unique(user_id, date)
);

alter table public.activities enable row level security;

create policy "Users can view their own activities." on activities for select using (auth.uid() = user_id);
create policy "Users can insert/update their own activities." on activities for all using (auth.uid() = user_id);


-- FEEDBACK TABLE (Added from feedback_schema)
create table if not exists public.feedback (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) not null,
  message text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.feedback enable row level security;

create policy "Users can submit feedback" on public.feedback for insert with check (auth.uid() = user_id);
create policy "Users can view their own feedback" on public.feedback for select using (auth.uid() = user_id);


-- ==========================================
-- 2. STORAGE BUCKETS
-- ==========================================

-- Ensure avatars bucket exists and is public
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

-- Storage Policies
-- Drop existing policies first to be safe when re-running
drop policy if exists "Avatar images are publicly accessible." on storage.objects;
drop policy if exists "Anyone can upload an avatar." on storage.objects;
drop policy if exists "Users can update their own avatar." on storage.objects;

create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Users can update their own avatar." on storage.objects
  for update using (bucket_id = 'avatars');
