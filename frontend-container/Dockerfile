FROM ubuntu:14.04
MAINTAINER Lucas Lobosque <lucaslobosque@gmail.com>

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.11.1

#config to allow bower run as root
RUN echo '{ "allow_root": true }' > /root/.bowerrc

# Let the conatiner know that there is no tty
#ENV DEBIAN_FRONTEND noninteractive

# Install Packages
RUN apt-get update && apt-get install -y \
        curl phantomjs make git-core

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash \
&& source $NVM_DIR/nvm.sh \
&& nvm install $NODE_VERSION \
&& nvm alias default $NODE_VERSION \
&& nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Ensure that Python outputs everything that's printed inside
# the application rather than buffering it.
WORKDIR /opt/frontend/
CMD ["make", "watch"]
