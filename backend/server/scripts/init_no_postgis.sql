-- If you cannot enable PostGIS, use this schema instead
create extension if not exists pgcrypto;

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
  location jsonb -- store lat/lng or geojson
);

create table if not exists ticket_updates (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references tickets(id) on delete cascade,
  message text not null,
  created_at timestamptz default now(),
  created_by uuid references users(id)
);

create table if not exists services (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  department text,
  description text
);

create table if not exists service_requests (
  id uuid primary key default gen_random_uuid(),
  status text check (status in ('pending','in_progress','completed','cancelled')) default 'pending',
  created_by uuid references users(id) on delete cascade,
  service_id uuid references services(id),
  address text,
  created_time timestamptz default now()
);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid references tickets(id) on delete cascade,
  message text not null,
  created_at timestamptz default now(),
  created_by uuid references users(id)
);


