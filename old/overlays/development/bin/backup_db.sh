#!/usr/bin/env bash

date
echo "hello from a Bootiful Podcast Backup ($(uname -a) backup.sh"

apt-get update
apt -y upgrade

# apt-get -y install postgresql-client-13 || echo "could not install PSQL 13" &&
apt-get -y install postgresql-client

apt-get -y install git curl jq

export PGPASSWORD=${POSTGRES_PASSWORD}
export BACKUPS_DIR=/backups/postgresql
export LATEST_SQL=$BACKUPS_DIR/latest.sql

mkdir -p $BACKUPS_DIR

function backup_date_string() {
  date +'%d_%m_%Y__%H_%M_%S'
}

function initialize_db() {
  echo "Need to create the DB"
  ls -la $LATEST_SQL || echo "we don't have a latest.sql "
  cat $LATEST_SQL | psql -v ON_ERROR_STOP=0 -U ${POSTGRES_USER} -h ${POSTGRES_SERVICE_HOST} -p ${POSTGRES_SERVICE_PORT} ${POSTGRES_DB}
}

function backup_db() {
  echo "BACKUP STARTING"
  BACKUP_ROOT_FN=$(backup_date_string)
  BACKUP=$BACKUPS_DIR/${BACKUP_ROOT_FN}.sql
  BACKUP_TGZ=$BACKUPS_DIR/${BACKUP_ROOT_FN}.tgz
  echo "Saving to ${BACKUP}"
  TMP_BACKUP=mybackup.sql

  pg_dump -U ${POSTGRES_USER} -h ${POSTGRES_SERVICE_HOST} -p ${POSTGRES_SERVICE_PORT} --format=plain -d ${POSTGRES_DB} >$TMP_BACKUP

  du -hs $TMP_BACKUP || echo "Could not create ${TMP_BACKUP} "

  cp $TMP_BACKUP $BACKUP
  cp $TMP_BACKUP $LATEST_SQL
  ls -la $BACKUP || echo "Could not successfully backup the database!"

  tar -c $BACKUP | gzip -9 > $BACKUP_TGZ
  rm $BACKUP

  cat $LATEST_SQL

  echo "BACKUP FINISHED"

}

#psql -v ON_ERROR_STOP=0 -U ${POSTGRES_USER} -h ${POSTGRES_SERVICE_HOST} -p ${POSTGRES_SERVICE_PORT} ${POSTGRES_DB} -tc " select count(*) from information_schema.tables where table_schema = 'public' " | grep -q 0 && initialize_db || echo "could not initialize DB, step 1"

#psql -v ON_ERROR_STOP=0 -U ${POSTGRES_USER} -h ${POSTGRES_SERVICE_HOST} -p ${POSTGRES_SERVICE_PORT} ${POSTGRES_DB} -tc " select count(*) from  podcast  " | grep -q 0 && initialize_db || echo "could not initialize DB, step 2"

backup_db

ls -la $BACKUPS_DIR/

#sleep 300