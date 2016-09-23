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


## Containers

Our composition is made of the following containers:

### frontend

(todo)

### backend

(todo)

### postgres

This is the [official postgres container](https://hub.docker.com/_/postgres/)
(todo)

### nginx

This is the [official nginx container](https://hub.docker.com/_/nginx/)
(todo)

### rabbitmq

This the [official nginx container](https://hub.docker.com/_/rabbitmq/)
(todo)

## Known Issues

* Docker does not handle well SIGINT (ctrl+c) signals, so it is pretty hard to stop/interrupt running tasks

## TODO/Roadmap/Improvements

* Logs: Currently all the containers output their stuff to STDOUT. We should make nginx, postgresql and rabbitmq
output their stuff in log files under a `logs/` folder.
* Worker: Make a container to run the main worker (celery):
`python manage.py celery -A contentools -l info worker --concurrency=1 -Ofair --statedb=%n.state`
* Cron: Make a container to run the cron worker (celery):
`celery -A contentools beat`
* Use a configuration file for gunicorn instead running it with lots of arguments
* Refactor restore_db.sh (backend project) to use env variables instead hardcoded address/user
* It would be a good idea to use non-standard ports to avoid conflicts with services already running into the
host machine
