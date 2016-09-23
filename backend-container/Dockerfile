FROM ubuntu:14.04
MAINTAINER Lucas Lobosque <lucaslobosque@gmail.com>

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Install Packages
RUN apt-get update && apt-get install -y \
		curl \
		libpq-dev \
		python3 \
		python3-dev \
		python-virtualenv \
        libncurses5-dev \
        build-essential \
        gettext \
        git-core

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Ensure that Python outputs everything that's printed inside
# the application rather than buffering it.
ENV PYTHONUNBUFFERED 1
COPY entrypoint.sh /backend-entrypoint.sh
WORKDIR /opt/backend
ENTRYPOINT ["make"]
