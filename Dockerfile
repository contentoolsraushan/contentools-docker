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
#ENV BACKEND_KEY ${SSH_DIR}docker-backend
#ENV FRONTEND_KEY ${SSH_DIR}docker-frontend

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
#	echo "IdentityFile ${BACKEND_KEY}" >> /etc/ssh/ssh_config && \

# Fetch and build frontend repository into contentool dir
ADD docker-frontend ${SSH_DIR}id_rsa
RUN chmod 600 ${SSH_DIR}id_rsa && \
	git clone git@github.com:contentools/frontend.git ${FRONTEND_FOLDER}
	cd ${FRONTEND_FOLDER} && \
	git checkout dev && \
	make build
#	echo "IdentityFile ${FRONTEND_KEY}" >> /etc/ssh/ssh_config
	
# Create symlinks
RUN \
	cd ${BACKEND_FOLDER} && \
	ln -s ${FRONTEND_FOLDER} && \
	cd /opt && \
	ln -s ${BACKEND_FOLDER} contentools

# Install autoenv
RUN	pip install autoenv
COPY .env ${BACKEND_FOLDER}
RUN	autoenv

# Contentools create database
COPY start_postgres.sh /root/start_postgres.sh
CMD ["/root/start_postgres.sh"]

# Nginx
RUN \
	rm -f /etc/nginx/nginx.conf \
	ln -s ${BACKEND_FOLDER}/conf/nginx.dev.conf /etc/nginx/nginx.conf \
	service nginx restart


# Virtual env e run platform
RUN \
	cd ${BACKEND_FOLDER} && \
	source venv/bin/activate && \
	source .env && \
	pip install -r requirements.txt && \
	python manage.py migrate_schemas --shared &&
	./restore_schemas.sh && \
	foreman start

EXPOSE 5000