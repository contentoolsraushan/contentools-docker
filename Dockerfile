FROM ubuntu:14.04
MAINTAINER Davi Candido <davivc@gmail.com>

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

# Install Packages
RUN \	
	apt-get update && \
	apt-get install -y \
		curl \
		nginx \
		libpq-dev \
		python3-dev \
		python-virtualenv \
		rabbitmq-server \
		git-core 

RUN \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" \
       > /etc/apt/sources.list.d/pgdg.list && \
  	curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
       | apt-key add - && \
	apt-get update && \
	apt-get install -y \
		postgresql-${PG_VERSION} \
		postgresql-contrib-${PG_VERSION}

# Create contentools dir
#RUN cd ~/ && \
#	mkdir contentools && \


# Make ssh dir
RUN mkdir ${SSH_DIR}

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add github to known hosts
RUN ssh-keyscan -T 30 github.com >> /root/.ssh/known_hosts

# Fetch backend repository into contentool dir
ADD docker-backend ${SSH_DIR}id_rsa
RUN chmod 600 ${SSH_DIR}id_rsa && \
	git clone git@github.com:contentools/backend.git ${BACKEND_FOLDER} && \
	cd ${BACKEND_FOLDER} && \
	git checkout dev

# Instal nodejs
RUN \
	apt-get install -y nodejs nodejs-legacy npm build-essential

# Fetch and build frontend repository into contentool dir
ADD docker-frontend ${SSH_DIR}id_rsa
RUN \
	chmod 600 ${SSH_DIR}id_rsa && \
	git clone git@github.com:contentools/frontend.git ${FRONTEND_FOLDER} && \
	cd ${FRONTEND_FOLDER} && \
	git checkout dev 

# Build the frontend
RUN \
	cd ${FRONTEND_FOLDER} && \
	rm -rf node_modules/ && \
	rm -rf ~/.npm && \
	npm install -g bower && \
	npm install -g grunt-wiredep && \
	bower install --allow-root && \
	npm cache clean && \
#   npm install && \
	make build
	
# Create symlinks
RUN \
	cd ${BACKEND_FOLDER} && \
	ln -s ${FRONTEND_FOLDER} && \
	cd /opt && \
	ln -s ${BACKEND_FOLDER} contentools

# Contentools create database
COPY start_postgres.sh /root/start_postgres.sh
CMD ["/root/start_postgres.sh"]

# Nginx
RUN \
	rm -f /etc/nginx/nginx.conf && \
	ln -s ${BACKEND_FOLDER}/conf/nginx.dev.conf /etc/nginx/nginx.conf && \
	service nginx restart

# Virtual env e run platform
RUN \
	cd ${BACKEND_FOLDER} && \
	cp .env.example .env

RUN \
	virtualenv venv --python=python3

# Install foreman
RUN \
	apt-get -y install ca-certificates wget && \
	wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
	dpkg -i puppetlabs-release-trusty.deb

RUN \ 
	echo "deb http://deb.theforeman.org/ trusty 1.9" > /etc/apt/sources.list.d/foreman.list && \
	echo "deb http://deb.theforeman.org/ plugins 1.9" >> /etc/apt/sources.list.d/foreman.list && \
	wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -

RUN \
	apt-get update && \
	apt-get -y install foreman-installer && \
	foreman-installer

# Install requirements and run plataform
RUN \
	source venv/bin/activate && \
	source .env && \
	export DATABASE_URL=postgres://contentools_dev:12345@localhost:5432/contentools && \
	pip install -r requirements.txt && \
	python manage.py migrate_schemas --shared && \
	yes | ./restore_schemas.sh contentools && \
	nohup foreman start > /var/log/contentools_docker.log 2>&1 &

EXPOSE 5000

# is not recommended as it persists in the final image
# but this avoid TERM error during build
# ENV DEBIAN_FRONTEND noninteractive
