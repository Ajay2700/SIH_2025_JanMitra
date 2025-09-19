-- Seed dummy data (PostGIS variant)
-- Pre-req:
-- 1) Run init.sql
-- 2) Ensure default users exist: citizen@example.com, staff@example.com, admin@example.com

-- Upsert services
insert into services(name, department, description) values
  ('Road Repair','Public Works','Fixing potholes and roads'),
  ('Garbage Collection','Sanitation','Waste pickup and cleanliness'),
  ('Water Supply','Water Board','Water connection and leakage'),
  ('Street Lights','Electrical','Street light maintenance')
on conflict (name) do update
  set department = excluded.department,
      description = excluded.description;

-- Insert tickets and initial updates
with citizen as (
  select id as cid from users where email = 'citizen@example.com'
), staff as (
  select id as sid from users where email = 'staff@example.com'
), adminu as (
  select id as aid from users where email = 'admin@example.com'
), inserted as (
  insert into tickets (status, created_by, address, priority, assigned_to, eta_time, description, photo_url, location)
  values
  ('open',         (select cid from citizen), 'Hyderabad, TS', 'medium', null,                     null,                      'Pothole on main road near signal', null, ST_SetSRID(ST_MakePoint(78.4867, 17.3850), 4326)),
  ('assigned',     (select cid from citizen), 'Hyderabad, TS', 'high',   (select sid from staff), now() + interval '2 days', 'Garbage pile-up in colony',         null, ST_SetSRID(ST_MakePoint(78.4900, 17.3900), 4326)),
  ('in_progress',  (select cid from citizen), 'Hyderabad, TS', 'medium', (select sid from staff), now() + interval '1 day',  'Street light not working',          null, ST_SetSRID(ST_MakePoint(78.4850, 17.3800), 4326)),
  ('resolved',     (select cid from citizen), 'Hyderabad, TS', 'low',    (select sid from staff), now() - interval '1 hour', 'Water leakage in lane',             null, ST_SetSRID(ST_MakePoint(78.4800, 17.3700), 4326)),
  ('closed',       (select cid from citizen), 'Hyderabad, TS', 'low',    null,                     null,                      'Stray dogs issue',                  null, ST_SetSRID(ST_MakePoint(78.4700, 17.3600), 4326))
  returning id, description
)
insert into ticket_updates(ticket_id, message, created_by)
select i.id, 'Ticket created', (select cid from citizen) from inserted i;

-- Add more timeline updates to certain tickets
insert into ticket_updates(ticket_id, message, created_by)
select t.id, 'Assigned to staff', (select aid from adminu)
from tickets t where t.description = 'Garbage pile-up in colony';

insert into ticket_updates(ticket_id, message, created_by)
select t.id, 'Work started', (select sid from staff)
from tickets t where t.description = 'Street light not working';

insert into ticket_updates(ticket_id, message, created_by)
select t.id, 'Issue resolved', (select sid from staff)
from tickets t where t.description = 'Water leakage in lane';

-- Service requests
with citizen as (
  select id as cid from users where email = 'citizen@example.com'
)
insert into service_requests(status, created_by, service_id, address)
select 'pending', (select cid from citizen), s.id, 'Hyderabad, TS'
from services s
where s.name in ('Water Supply','Street Lights');

-- Notifications
insert into notifications(ticket_id, message, created_by)
select t.id, 'We have received your ticket', u.id
from tickets t
join users u on u.email = 'staff@example.com'
order by t.created_time desc
limit 3;


