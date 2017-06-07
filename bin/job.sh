#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)

function backup_db {
  DB=$1
  BACKUP_DIR="$BACKUP_DATA_DIR/$DB"

  mkdir -p $BACKUP_DIR
  dump=$(mysqldump --user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_SERVICE_HOST $DB)

  if [ $? -ne 0 ]; then
    echo "mysqldump not successful: ${DATE}"
    exit 1
  fi

  printf '%s' "$dump" | gzip > $BACKUP_DIR/dump-${DATE}.sql.gz

  if [ $? -eq 0 ]; then
    echo "backup created: ${DATE}"
  else
    echo "backup not successful: ${DATE}"
    exit 1
  fi

  # Delete old files
  old_dumps=$(ls -1 $BACKUP_DIR/dump* | head -n -$BACKUP_KEEP)
  if [ "$old_dumps" ]; then
    echo "Deleting: $old_dumps"
    rm $old_dumps
  fi
}

databases=`mysql --user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_SERVICE_HOST -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  backup_db $db
done
