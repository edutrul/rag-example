#!/usr/bin/env bash
set -euo pipefail

# Create the two practice databases if missing, preserving existing work.
psql --username "$POSTGRES_USER" --dbname postgres --set ON_ERROR_STOP=1 <<'SQL'
SELECT 'CREATE DATABASE practica_sql'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'practica_sql')
\gexec
SELECT 'CREATE DATABASE practica_vectorial'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'practica_vectorial')
\gexec
SQL

psql --username "$POSTGRES_USER" --dbname practica_sql \
    --set ON_ERROR_STOP=1 --file /lab-sql/01-practica-sql.sql
psql --username "$POSTGRES_USER" --dbname practica_vectorial \
    --set ON_ERROR_STOP=1 --file /lab-sql/02-practica-vectorial.sql
