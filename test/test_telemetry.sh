#!/bin/sh
PATH=/usr/local/postgres64_92/bin:$PATH
export PATH

printf '\033[1;32m%s\033[0m\n' 'Resetting'
rm -rf teltestdata > /dev/null 2>&1
mkdir -p teltestdata
pkill -9 -u majid postgres
pkill -9 plptel

printf '\033[1;32m%s\033[0m\n' 'Initializing database'
echo "sop" > password
initdb --encoding=UTF8 --auth=md5 --pwfile=password -U postgres -D teltestdata
rm password
cat >> teltestdata/postgresql.conf <<EOF
port = 5433
EOF

printf '\033[1;32m%s\033[0m\n' 'Starting database'
pg_ctl -D teltestdata start

printf '\033[1;32m%s\033[0m\n' 'Waiting for database to be ready'
until psql -p 5433 -U postgres postgres -c "select current_date;">/dev/null; do
    #echo waiting for PG to come up
    sleep 1
done

printf '\033[1;32m%s\033[0m\n' 'Setting up PL/Proxy in database'
psql -h localhost -p 5433 -U postgres postgres <<EOF
--DROP SERVER IF EXISTS sop CASCADE;
CREATE EXTENSION plproxy;
CREATE SERVER sop FOREIGN DATA WRAPPER PLPROXY 
OPTIONS (
  connection_lifetime '1800',
  telemetry 'localhost:4480',
  disable_binary '1',
  p0 'dbname=postgres user=postgres host=localhost port=5433 application_name=p0 password=sop',
  p1 'dbname=postgres user=postgres host=localhost port=5433 application_name=p1 password=sop',
  p2 'dbname=postgres user=postgres host=localhost port=5433 application_name=p2 password=sop',
  p3 'dbname=postgres user=postgres host=localhost port=5433 application_name=p3 password=sop'
);
CREATE USER MAPPING FOR postgres SERVER sop OPTIONS (user 'postgres', password 'sop');
DROP TABLE IF EXISTS plproxy_telemetry;

CREATE TABLE plproxy_telemetry(
  origin        TIMESTAMP,
  hostname      TEXT,
  partition     INTEGER,
  funcname      TEXT,
  calls         BIGINT,
  cache_hit     BIGINT,
  connect_time  FLOAT,
  total_time    FLOAT,
  time_p95      FLOAT,
  PRIMARY KEY   (origin, hostname, partition, funcname)
);
COMMENT ON TABLE plproxy_telemetry IS
  'Telemetry table for individual PL/Proxy shard calls';
COMMENT ON COLUMN plproxy_telemetry.calls IS
  'Number of calls to the stored procedure';
COMMENT ON COLUMN plproxy_telemetry.cache_hit IS
  'Number of remote calls that could reuse an already established connection';
COMMENT ON COLUMN plproxy_telemetry.connect_time IS
  'Total time spent in connection establishment, in milliseconds';
COMMENT ON COLUMN plproxy_telemetry.total_time IS
  'Total time spent (including connection) in milliseconds';
COMMENT ON COLUMN plproxy_telemetry.time_p95 IS
  '95th percentile of stored procedure execution time';

CREATE TABLE plproxy_details(
  origin        BIGINT,
  ip_port       TEXT,
  txid          INTEGER,
  connect_time  BIGINT,
  conn_age      BIGINT,
  total_time    BIGINT,
  funcname      TEXT,
  dest          TEXT,
  partition     SMALLINT
);
CREATE INDEX plproxy_details_i ON plproxy_details(ip_port, txid, partition);
EOF

printf '\033[1;32m%s\033[0m\n' 'Running PL/Proxy tests'
psql -h localhost -p 5433 -U postgres postgres -c "select pg_backend_pid();"
sleep 5
psql -h localhost -p 5433 -U postgres postgres < sql/telemetry.sql

#printf '\033[1;32m%s\033[0m\n' 'Shutting down'
#pg_ctl -D teltestdata stop -m immediate
#pkill -9 -u majid postgres
