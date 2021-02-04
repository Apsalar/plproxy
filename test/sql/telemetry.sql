--create schema plproxy;

-- drop server sop cascade;
-- create server sop foreign data wrapper plproxy 
-- options (
--   connection_lifetime '1800',
--   telemetry 'dev:4480',
--   disable_binary '1',
--   p0 'dbname=realserver user=postgres host=dev port=6432 application_name=p0 password=kefta',
--   p1 'dbname=realserver user=postgres host=dev port=6432 application_name=p1 password=kefta',
--   p2 'dbname=realserver user=postgres host=dev port=6432 application_name=p2 password=kefta',
--   p3 'dbname=realserver user=postgres host=dev port=6432 application_name=p3 password=kefta'
-- );
-- create user mapping for postgres server sop options (user 'postgres', password 'kefta');

create or replace function sop() returns setof text as $$
cluster 'sop';
run on all;
select application_name||':'||pg_backend_pid()||pg_sleep(
  case (select application_name from pg_stat_activity where pid=pg_backend_pid())
  when 'p0' then 1.0
  when 'p1' then 2.0
  when 'p2' then 3.0
  when 'p3' then 4.0
  else 0.0 end)
from pg_stat_activity where pid=pg_backend_pid();
$$ language plproxy security definer;

create or replace function sopo() returns setof text as $$
cluster 'sop';
run on any;
select application_name||':'||pg_backend_pid()||pg_sleep(
  case (select application_name from pg_stat_activity where pid=pg_backend_pid())
  when 'p0' then 1.0
  when 'p1' then 2.0
  when 'p2' then 3.0
  when 'p3' then 4.0
  else 0.0 end)
from pg_stat_activity where pid=pg_backend_pid();
$$ language plproxy security definer;

select * from pg_stat_activity;

select sop();
select sopo();

select sop();
select sopo();

select * from pg_stat_activity;
