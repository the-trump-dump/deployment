#!/usr/bin/env bash
set -e
set -o pipefail

DB_NAME=bp # todo use this variable in the DDL below

function initialize_db() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"  <<-EOSQL
    CREATE USER ${$POSTGRES_DB};
    CREATE DATABASE ${$POSTGRES_DB};
    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${$POSTGRES_USER};
EOSQL
}

echo "Initializing Postgres DB."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tc "SELECT 1 FROM pg_database WHERE datname = 'bp'" | grep -q 1 || initialize_db
echo "Done creating DB $POSTGRES_DB with user $POSTGRES_USER "
