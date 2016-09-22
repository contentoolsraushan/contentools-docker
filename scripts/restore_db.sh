#!/bin/bash

createdb contentools -h 172.18.0.2 -U postgres
RESULT=$?

if [ $RESULT == 0 ]; then
    echo "[restore_db] Database not found - creating and populating..."
    psql -h 172.18.0.2 -U postgres -d contentools < /opt/backup/public.sql
    psql -h 172.18.0.2 -U postgres -d contentools < /opt/backup/contentools.sql
else
    echo "[restore_db] Database already created. skipping..."
fi
