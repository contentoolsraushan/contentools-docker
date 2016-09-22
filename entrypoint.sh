#!bin/bash
source /opt/contentools/venv/bin/activate
cd /opt/contentools
DEBUG=True gunicorn contentools.wsgi:application --reload --workers 1 -b :5000 -k tornado -t 0
