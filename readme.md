Virtualized environment to run the Contentools stack using docker and docker-compose.
With this project, you don't need to install anything from our stack to have it running.

## Pre-requisites

To run the containers, you need:
* [Docker](https://docs.docker.com/engine/installation/) (1.21.1 or higher)
* [Docker Compose](https://docs.docker.com/compose/install/) (1.8 or higher)

*Not familiar with docker? Then you should [read this](https://prakhar.me/docker-curriculum/)*.

## Install

Clone the backend and the frontend repository to the code folder:

```
$ git clone git@gitlab.com:contentools/frontend.git code/frontend
$ git clone git@gitlab.com:contentools/backend.git  code/backend
```

Now you need to build the containers that we will use:
```
$ docker-compose build
```

Use these containers to get that source code you just
cloned and build them to be able to run the platform:
```
$ docker-compose run --rm frontend build
$ docker-compose run --rm backend build
```

## Configurations & Database

### Hosts

You need to add two domains to your hosts file.
This is very important: our application will deny connections from other domains.

```
127.0.0.1 go.contentools.dev
127.0.0.1 contentools.contentools.dev
```

### Database

*Confused about the hosts file? Check [this article](http://www.bleepingcomputer.com/tutorials/hosts-files-explained/)*

It is recommended that you use a database backup to populate it before running the stack.
Get the database backup files and put them under the `backup/` folder and then:

```
$ docker-compose run --rm backend restore
```

## Firing up the stack

```
 docker-compose up
```

(todo)

## Known Issues

* Docker does not handle well SIGINT (ctrl+c) signals, so it is pretty hard to stop/interrupt running tasks

(todo)

## Roadmap/Improvements

(todo)
