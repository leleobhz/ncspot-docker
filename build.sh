#!/usr/bin/env bash

docker image rm -f docker-ncspot:latest
docker build --tag 'docker-ncspot:latest' .
