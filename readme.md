## Install

Clone the backend and the frontend repository to the code folder:

```
$ git clone git@gitlab.com:contentools/frontend.git code/frontend
$ git clone git@gitlab.com:contentools/backend.git code/backend
```

Now you need to build the containers that run build related commands for each of the projects:
```
$ docker build -t contentools/frontend-container ./frontend-container
$ docker build -t contentools/backend-container ./backend-container
```

Use these containers to get that source code you just cloned and build them to be able to run the platform:
```
$ docker run --rm -v $(pwd)/code/frontend:/opt/frontend/ contentools/frontend-container make build
$ docker run --rm -v $(pwd)/code/frontend:/opt/backend/ contentools/backend-container make build
```
*$(pwd) is used because docker do not accept relative directories. Use the absolute path instead $(pwd) in non-UNIX environments.*

## Firing up the stack
