#!bin/bash

cd /opt/backend
virtualenv venv --python=python3
source venv/bin/activate
make build
