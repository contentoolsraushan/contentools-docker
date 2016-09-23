Virtualized environment to run the Contentools stack using docker and docker-compose. With this project, you don't need to install anything from our stack to have it running.

## Pre-requisites

To run the containers, you need:
* [Docker](https://docs.docker.com/engine/installation/) (1.21.1 or higher)
* [Docker Compose](https://docs.docker.com/compose/install/) (1.8 or higher)

*Not familiar with docker? Then you should [read this](https://prakhar.me/docker-curriculum/)*.

## Install

Clone the backend and the frontend repository to the code folder:

```
$ git clone git@gitlab.com:contentools/frontend.git code/frontend
$ git clone git@gitlab.com:contentools/backend.git code/backend
```

Now you need to build the containers that we will use:
```
$ docker build -t contentools/frontend-container ./frontend-container
$ docker build -t contentools/backend-container ./backend-container
$ docker-compose build
```

Use these containers to get that source code you just cloned and build them to be able to run the platform:
```
$ docker run --rm -v $(pwd)/code/frontend:/opt/frontend/ contentools/frontend-container build
$ docker run --rm -v $(pwd)/code/frontend:/opt/backend/ contentools/backend-container build
```
*$(pwd) is used because docker do not accept relative directories. Use the absolute path instead $(pwd) in non-UNIX environments.*

## Firing up the stack

(todo)

## Known Issues

* Docker does not handle well SIGINT (ctrl+c) signals, so it is pretty hard to stop/interrupt running tasks

(todo)

## Roadmap/Improvements

(todo)
