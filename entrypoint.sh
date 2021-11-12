#!/usr/bin/env bash

TIME=$(date +%b-%d-%y-%H%M)
FILENAME="backup-$TIME.tar.gz"
TMP_DIR=/tmp

DATABASES_TOTAL=${#DATABASES[@]}

function backupDatabase() {
  database=$1
  if [[ " ${IGNORED_DATABASES[@]} " =~ " ${database} " ]]; then
    printf "$database ignored\n"
  else
    printf "Backing up $database\n"

    set echo off
    mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$database" >"$TMP_DIR/$database.sql"
    tar -cpzf "$TMP_DIR/$database-$FILENAME" "$TMP_DIR/$database.sql"
    set echo on

    printf "Uploading to S3...\n"
    aws s3 cp "$TMP_DIR/$database-$FILENAME" "s3://$S3_BUCKET_NAME/$S3_FOLDER/$database-$FILENAME"
    printf "Uploaded to S3.\n"

    printf "Cleaning up...\n"
    rm -rf "$TMP_DIR/$database-$FILENAME"
    printf "Cleaned up.\n"
  fi
}

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

if [[ $DATABASES_TOTAL -eq 0 ]]; then
  DATABASES=$(echo "show databases;" | mysql -h "$DB_HOST" -p"$DB_PASSWORD" -u "$DB_USER")
fi

for i in ${DATABASES[@]}; do
  backupDatabase $i
done
