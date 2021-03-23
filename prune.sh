#!/bin/sh
set -e
hash podman >/dev/null 2>&1 && alias docker=podman
docker rmi $(docker images | grep adshell- | tr -s ' ' | cut -d ' ' -f 3)
