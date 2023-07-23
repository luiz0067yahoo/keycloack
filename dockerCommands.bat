@echo off

set "container=keycloak.container"
set "image=keycloak.image"

:check_image
set "imageExists="
docker images | findstr /C:"%image%" >nul
if %errorlevel% equ 0 (
    set "imageExists=true"
)

if "%1" == "start" (
    call :check_container
    if %errorlevel% equ 0 (
        docker start "%container%"
    ) else (
        echo Container %container% not found.
    )
) else if "%1" == "stop" (
    call :check_container
    if %errorlevel% equ 0 (
        docker stop "%container%"
    ) else (
        echo Container %container% not found.
    )
) else if "%1" == "exec" (
    call :check_container
    if %errorlevel% equ 0 (
        docker exec "%container%"  "%2"
    ) else (
        echo Container %container% not found.
    )
) else if "%1" == "run" (
    call :docker_run
) else if "%1" == "rm" (
    call :check_container
    if %errorlevel% equ 0 (
        docker rm "%container%"
    ) else (
        echo Container %container% not found.
    )
) else if "%1" == "rm.image" (
    call :check_image
    if defined imageExists (
        docker rmi "%image%"
    ) else (
        echo Image %image% not found.
    )
) else if "%1" == "build" (
    call :check_image
    if defined imageExists (
        exit /b 0
    )
    docker build . -t "%image%"
) else if "%1" == "create" (
    call :check_image
    if defined imageExists (
        exit /b 0
    )
    docker build . -t "%image%"
    call :docker_run
) else if "%1" == "log" (
    call :check_image
    if defined imageExists (
       docker logs -f "%container%"
    )
) else if "%1" == "destroy" (
    call :check_container
    if %errorlevel% equ 0 (
        docker stop "%container%" && docker rm "%container%"
    ) else (
        echo Container %container% not found.
    )
    call :check_image
    if defined imageExists (
        docker rmi "%image%"
    ) else (
        echo Image %image% not found.
    )
) else if "%1" == "renew" (
    call :check_container
    if %errorlevel% equ 0 (
        docker stop "%container%" && docker rm "%container%"
    ) else (
        echo Container %container% not found.
    )
    call :check_image
    if defined imageExists (
        docker rmi "%image%"
    ) else (
        echo Image %image% not found.
    )
    call :check_image
    if defined imageExists (
        exit /b 0
    )
    docker build . -t "%image%"
    call :docker_run
) else (
    echo Unknown command. Use as argument.
    echo "build: build image"
    echo "create: build image and run container"
    echo "destroy: stop container, delete container, and image"
    echo "exec: run command terminal in container image"
    echo "renew:  stop container, delete container, image,build image and run container"
    echo "log:  show logs"
    echo "rm: delete container"
    echo "rm.image: delete image"
    echo "run: run image in container"
    echo "start: if container is stopped, start container"
    echo "stop: stop container"
)

exit /b

:check_container
set "containerExists="
for /f "tokens=*" %%i in ('docker ps -a') do (
    echo %%i | findstr /C:"%container%" >nul
    if not errorlevel 1 (
        set "containerExists=true"
    )
)

if defined containerExists (
    exit /b 0
) else (
    exit /b 1
)

:docker_run
call :check_image
if defined imageExists (
    docker run -p 8080:8080 -p 9990:9990 --network=bridge -e TZ=America/Sao_Paulo --restart=always --name "%container%" -d "%image%" 
) else (
    echo Image %image% not found. Execute 'build' to create the image before running the container.
)

exit /b