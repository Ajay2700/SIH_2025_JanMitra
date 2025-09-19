-- Enable extensions required by this schema
create extension if not exists pgcrypto; -- for gen_random_uuid()
create extension if not exists postgis;  -- for geometry(Point, 4326)

-- Users Table
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  password text not null,
  full_name text,
  phone_number text,
  address text,
  role text check (role in ('citizen','staff','admin')) default 'citizen',
  created_at timestamptz default now()
);

-- Tickets Table
create table if not exists tickets (
  id uuid primary key default gen_random_uuid(),
  status text check (status in ('open','assigned','in_progress','resolved','closed')) default 'open',
  created_by uuid references users(id) on delete cascade,
  created_time timestamptz default now(),
  address text,
  priority text check (priority in ('low','medium','high')) default 'medium',
  assigned_to uuid references users(id),
  eta_time timestamptz,
  up_votes int default 0,
  description text,
  photo_url text,
  location geometry(point, 4326)
);

-- Ticket Updates (timeline)
create table if not exists ticket_updates (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references tickets(id) on delete cascade,
  message text not null,
  created_at timestamptz default now(),
  created_by uuid references users(id)
);

-- Services Table
create table if not exists services (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  department text,
  description text
);

-- Service Requests Table
create table if not exists service_requests (
  id uuid primary key default gen_random_uuid(),
  status text check (status in ('pending','in_progress','completed','cancelled')) default 'pending',
  created_by uuid references users(id) on delete cascade,
  service_id uuid references services(id),
  address text,
  created_time timestamptz default now()
);

-- Notifications Table
create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references tickets(id) on delete cascade,
  message text not null,
  created_at timestamptz default now(),
  created_by uuid references users(id)
);

-- Analytics helper RPCs (placeholders, implement as needed)
-- create or replace function tickets_summary() returns json as $$
--   select json_build_object('total', count(*)) from tickets;
-- $$ language sql stable;

-- create or replace function departments_performance() returns json as $$
--   select json_agg(row_to_json(t)) from (
--     select department, count(*) as tickets from services group by 1
--   ) t;
-- $$ language sql stable;

-- create or replace function trending_issues() returns json as $$
--   select json_agg(row_to_json(t)) from (
--     select address, count(*) as count from tickets group by 1 order by 2 desc limit 10
--   ) t;
-- $$ language sql stable;


