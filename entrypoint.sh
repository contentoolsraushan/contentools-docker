#!bin/bash

./opt/scripts/restore_db.sh
source /opt/contentools/venv/bin/activate
cd /opt/contentools
/bin/sleep 1
DEBUG=True gunicorn contentools.wsgi:application --reload --workers 1 -b :5000 -k tornado -t 0
