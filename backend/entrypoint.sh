#!bin/bash

cd /opt/backend
source venv/bin/activate
gunicorn contentools.wsgi:application --workers 1 -b :5000 --reload
