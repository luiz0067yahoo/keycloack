#!/bin/bash

container="keycloak.container"
image="keycloak.image"

check_image() {
    imageExists=$(docker images | awk '{print $1}' | grep -q "^$image$")
}

check_container() {
    containerExists=$(docker ps -a | awk '{print $NF}' | grep -q "^${container}$")
}

docker_run() {
    check_image
    if [ "$imageExists" == true ]; then
        docker run -p 8080:8080 --network=bridge -e TZ=America/Sao_Paulo --restart=always --name "$container" -d "$image"
    else
        echo "Image $image not found. Execute 'build' to create the image before running the container."
    fi
}

if [ "$1" == "start" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker start "$container"
    else
        echo "Container $container not found."
    fi
elif [ "$1" == "stop" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker stop "$container"
    else
        echo "Container $container not found."
    fi
elif [ "$1" == "exec" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker exec "$container" "$2"
    else
        echo "Container $container not found."
    fi
elif [ "$1" == "run" ]; then
    docker_run
elif [ "$1" == "rm" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker rm "$container"
    else
        echo "Container $container not found."
    fi
elif [ "$1" == "rm.image" ]; then
    check_image
    if [ "$imageExists" == true ]; then
        docker rmi "$image"
    else
        echo "Image $image not found."
    fi
elif [ "$1" == "build" ]; then
    check_image
    if [ "$imageExists" == true ]; then
        exit 0
    fi
    docker build . -t "$image"
elif [ "$1" == "create" ]; then
    check_image
    if [ "$imageExists" == true ]; then
        exit 0
    fi
    docker build . -t "$image"
    docker_run
elif [ "$1" == "destroy" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker stop "$container" && docker rm "$container"
    else
        echo "Container $container not found."
    fi
    check_image
    if [ "$imageExists" == true ]; then
        docker rmi "$image"
    else
        echo "Image $image not found."
    fi
elif [ "$1" == "renew" ]; then
    check_container
    if [ "$containerExists" == true ]; then
        docker stop "$container" && docker rm "$container"
    else
        echo "Container $container not found."
    fi
    check_image
    if [ "$imageExists" == true ]; then
        docker rmi "$image"
    else
        echo "Image $image not found."
    fi
    check_image
    if [ "$imageExists" == true ]; then
        exit 0
    fi
    docker build . -t "$image"
    docker_run
elif [ "$1" == "log" ]; then
    check_image
    if [ "$imageExists" == true ]; then
        docker logs -f "$container"
    else
        echo "Image $image not found."
    fi
else
    echo "Unknown command. Use as argument."
    echo "build: build image"
    echo "create: build image and run container"
    echo "destroy: stop container, delete container, and image"
    echo "exec: run command terminal in container image"
    echo "renew: stop container, delete container, image, build image and run container"
    echo "log: show logs"
    echo "rm: delete container"
    echo "rm.image: delete image"
    echo "run: run image in container"
    echo "start: if container is stopped, start container"
    echo "stop: stop container"
fi

exit 0
