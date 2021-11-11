#!/usr/bin/env bash

TIME=$(date +%b-%d-%y-%H%M)
FILENAME="backup-$TIME.tar.gz"

IGNORED_DATABASES=(Database mysql information_schema performance_schema cond_instances)
DATABASE_NAMES=($(echo "show databases;" | mysql -h "$DB_HOST" -p"$DB_PASSWORD" -u "$DB_USER"))
TMP_DIR=/tmp

awscli configure set aws_access_key_id $AWS_ACCESS_KEY_ID
awscli configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

for i in "${DATABASE_NAMES[@]}"; do
  if [[ " ${IGNORED_DATABASES[@]} " =~ " ${i} " ]]; then
    printf "$i ignored\n"
  else
    printf "Backing up $i\n"

    set echo off
    mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$i" >"$TMP_DIR/$i.sql"
    tar -cpzf "$TMP_DIR/$i-$FILENAME" "$TMP_DIR/$i.sql"
    set echo on

    printf "Uploading to S3...\n"
    awscli s3 cp "$TMP_DIR/$i-$FILENAME" "s3://$S3_BUCKET_NAME/$S3_FOLDER/$i-$FILENAME"
    printf "Uploaded to S3.\n"
  fi
done
