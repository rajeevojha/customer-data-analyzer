#!/bin/bash
export REDIS_HOST=host.docker.internal
export REDIS_PORT=6379
export REDIS_USER=default
export REDIS_PASSWORD=""
echo "Environment variables set:"
env | grep REDIS
