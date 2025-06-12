#!/bin/bash
# Strict mode
set -euo pipefail
IFS=$'\n\t'

set +e

command -v ip 2> /dev/null

if [[ $? = 0 ]]; then
    export HOST_IP=$(ip -4 addr show docker0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
else
    export HOST_IP=$(ifconfig | grep "1[97]2.*" -m 1 | cut -d' ' -f 2 | xargs)
fi

set -e

IMPORTANT='\033[0;31m'
NC='\033[0m' # No Color

RESET_DATABASES=false

DATABASES=("al-powered-notes_local_db")
MYSQL_USER="root"
MYSQL_PASSWORD="password"
DOCKER_COMMAND_PREFIX=""

# --docker-root
if [[ $* == *--docker-root* ]]; then
    DOCKER_COMMAND_PREFIX="sudo "
fi

DATABASE_COMMAND_PREFIX="${DOCKER_COMMAND_PREFIX}docker-compose exec -T database mysql -u ${MYSQL_USER} -p\"${MYSQL_PASSWORD}\" --batch --skip-column-names -e"

# --reset
if [[ $* == *--reset* ]]; then
    RESET_DATABASES=true
    read -p "This will drop and recreate your local databases. Press y to confirm: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi
fi

# --local-db
if [[ $* == *--local-db* ]]; then
    DATABASE_COMMAND_PREFIX="mysql -u ${MYSQL_USER} --batch --skip-column-names -p\"${MYSQL_PASSWORD}\" -e"
fi

APP_DIRECTORY="$(pwd)/laravel-notes-service"

# Copy .env if missing
echo "Checking if .env files exist"
if [[ ! -f "${APP_DIRECTORY}/.env" ]]; then
    cp "${APP_DIRECTORY}/.env.example" "${APP_DIRECTORY}/.env"
fi

# cd "${APP_DIRECTORY}/docker"

# echo "HOST_IP=${HOST_IP}" > .env

APP_DIRECTORY="$(pwd)/raw-php-oauth-service"

# Copy .env if missing
echo "Checking if .env files exist"
if [[ ! -f "${APP_DIRECTORY}/.env" ]]; then
    cp "${APP_DIRECTORY}/.env.example" "${APP_DIRECTORY}/.env"
fi

# Stop and start docker
echo "Stopping docker if it's currently running"
eval "${DOCKER_COMMAND_PREFIX}docker-compose stop"

echo "Bringing up docker"
eval "${DOCKER_COMMAND_PREFIX}docker-compose up -d --remove-orphans"

# Wait for DB
set +e
echo "Waiting for database container to be ready..."

for i in {1..6}
do
    if [[ ${i} = 6 ]]; then
        echo "Timeout while waiting for database to come up"
        exit 1
    fi
    DB_EXISTS=$(eval "${DATABASE_COMMAND_PREFIX} \"\" 2> /dev/null")
    if [[ $? = 0 ]]; then
        break
    fi
    sleep 5
done

set -e

# Create/reset databases
echo "Checking state of databases"

for database in ${DATABASES[*]}; do
    if [[ ${RESET_DATABASES} = true ]]; then
        eval "${DATABASE_COMMAND_PREFIX} \"DROP DATABASE IF EXISTS ${database};\""
    fi

    DB_EXISTS=$(eval "${DATABASE_COMMAND_PREFIX} \"SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${database}';\" 2>&1 | grep -v \"mysql:\")"

    if [[ "${DB_EXISTS}" = "1" ]]; then
        echo "${database} exists, skipping"
        continue
    fi

    echo "Creating ${database}"
    eval "${DATABASE_COMMAND_PREFIX} \"CREATE DATABASE ${database} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
done

# Raw PHP Oauth Service Composer setup
echo "Installing composer packages for raw-php-oauth-service"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it raw-php-oauth-service-app composer install"

# Laravel project setup
echo "Running composer install"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app composer install"

echo "Running Laravel migrations and seeders"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan migrate"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan db:seed"

echo "Clearing Laravel caches"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan cache:clear"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan config:clear"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan view:clear"
eval "${DOCKER_COMMAND_PREFIX}docker exec -it laravel-notes-service-app php artisan optimize:clear"

echo "All Done!"
echo "Go to http://al-powered-notes-dev.io to see it in action"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
