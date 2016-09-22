FROM ubuntu:14.04
MAINTAINER Lucas Lobosque <lucaslobosque@gmail.com>

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV PG_VERSION 9.4
ENV USER contentools_dev
ENV PASS 12345
ENV BACKEND_FOLDER /root/contentools/backend
ENV FRONTEND_FOLDER /root/contentools/frontend

ENV SSH_DIR /root/.ssh/

ENV PROUDCTION_DB_URL a

ENV FRONTEND_GIT_URL git@gitlab.com:contentools/frontend.git
ENV BACKEND_GIT_URL git@gitlab.com:contentools/backend.git

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.11.1

#config to allow bower run as root
RUN echo '{ "allow_root": true }' > /root/.bowerrc

# Let the conatiner know that there is no tty
#ENV DEBIAN_FRONTEND noninteractive

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Install Packages
RUN apt-get update && apt-get install -y \
		curl \
		libpq-dev \
		python3 \
		python3-dev \
		python-virtualenv \
		rabbitmq-server \
		git-core \
        libncurses5-dev \
        ruby-full \
        build-essential \
        gettext \
        phantomjs \
        postgresql-client

ENV PHANTOMJS_BIN /usr/bin/phantomjs

RUN gem install foreman

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash \
&& source $NVM_DIR/nvm.sh \
&& nvm install $NODE_VERSION \
&& nvm alias default $NODE_VERSION \
&& nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Make ssh dir
RUN mkdir ${SSH_DIR}

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add gitlab to known hosts
RUN ssh-keyscan -T 30 gitlab.com >> /root/.ssh/known_hosts

# Fetch backend repository into contentool dir
ADD docker-backend ${SSH_DIR}id_rsa

RUN chmod 600 ${SSH_DIR}id_rsa

RUN \
    git clone ${BACKEND_GIT_URL} ${BACKEND_FOLDER} && \
	cd ${BACKEND_FOLDER} && \
	git checkout dev && \
    git pull --rebase

# Fetch and build frontend repository into contentool dir
RUN \
    git clone ${FRONTEND_GIT_URL} ${FRONTEND_FOLDER} && \
	cd ${FRONTEND_FOLDER} && \
	git checkout dev && \
    git pull --rebase

# Build the backend
RUN \
	cd ${BACKEND_FOLDER} && \
	cp .env.example .env && \
    source ${BACKEND_FOLDER}/.env

RUN \
	cd ${BACKEND_FOLDER} && \
	virtualenv venv --python=python3 && \
    source venv/bin/activate && \
    make build
    #make test


# Build the frontend
RUN \
	cd ${FRONTEND_FOLDER} && \
	make build

#RUN \
#	cd ${FRONTEND_FOLDER} && \
#	export PHANTOMJS_BIN=/usr/bin/phantomjs
#   make test
	
# Create symlinks
RUN \
	cd ${BACKEND_FOLDER} && \
	ln -s ${FRONTEND_FOLDER} && \
	cd /opt && \
	ln -s ${BACKEND_FOLDER} contentools

ADD backup/ /opt/contentools/tmp

# Install requirements and run plataform
RUN \
	cd ${BACKEND_FOLDER} && \
	source venv/bin/activate && \
    export PRODUCTION_DB_URL=postgres://contentools:content1550@contentools-saas.ceajwush8ru3.us-west-1.rds.amazonaws.com:5432/contentools && \
    export DATABASE_URL=postgres://postgres@localhost:5433/contentools && \
	yes | ./restore-schema.sh contentools

ENTRYPOINT ["nohup foreman start > /var/log/contentools_docker.log 2>&1 &"]

EXPOSE 5000
