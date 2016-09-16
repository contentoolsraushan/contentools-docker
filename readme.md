Requirements

Docker
Virtualbox (linux/Mac)
Hyper-V (Windows 10)

Build image from Dockerfile (this step is not necessary to be able to run the image).
$ docker build -t local:version .
$ docker tag local:version davivc/contentools:version
$ docker tag davivc/contentools:version davivc/contentools:latest
$ docker push davivc/contentools:version
$ docker push davivc/contentools:latest

# Run image with a working platform 
$ docker run -dit davivc/contentools:latest /bin/bash

# If you want to work only the backend in your host machine
$ docker run -i -t -v /local/pah/to/backend:/root/contentools/backend davivc/contentools:version /bin/bash

# If you want to work only the frontend in your host machine
$ docker run -i -t -v /local/pah/to/frontent:/root/contentools/frontend davivc/contentools:version /bin/bash

# If you want to work the backend and the frontend in your host machine
# backend and frontend must be inside the same folder as follows:
# content_platform_folder/
#    - backend/
#    - frontend/
$ docker run -i -t -v /local/pah/to/content_platform_folder:/root/contentools davivc/contentools:version /bin/bash

# Retrieve the list of running container
$ docker ps
$ docker ps -a (list all)

# Shell of the running container
$ docker exec -it container_id /bin/bash