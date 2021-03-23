#!/bin/sh
set -e

# Handle podman
hash podman >/dev/null 2>&1 && alias docker=podman

# Handle cli args
while [ -n "$1" ]; do
  case "$1" in
    --silent) SILENT=yes;;
    --username) USERNM="$2"; shift 1;;
    --password) PASSWD="$2"; shift 1;;
    # --persist) PERSIST=yes;;
    *) echo "Unknown arg $1"; exit 1;;
  esac
  shift 1
done

# Warn about default user / password
[ -z "$USERNM" ] && USERNM=user && echo "Using default username \"user\""
[ -z "$PASSWD" ] && PASSWD=pass && echo "Using default password \"pass\""

# Enable silent
# Conditional silence trick learned here
# https://stackoverflow.com/questions/314675/how-to-redirect-output-of-an-entire-shell-script-within-the-script-itself
[ -n "$SILENT" ] && exec 3>&1 4>&2 1>/dev/null 2>&1

# Build unminimized ubuntu image if necessary
if [ -z "$(docker images -q adshell-base)" ]; then
  docker build . -t "adshell-base" -f Dockerfile.adshell-base
fi

# Build custom image with specified username and password if necessary
TAG="adshell-$USERNM-$PASSWD"
if [ -z "$(docker images -q $TAG)" ]; then
  docker build . -t "$TAG" -f Dockerfile.adshell \
    --build-arg username="$USERNM" \
    --build-arg password="$PASSWD"
fi

# Disable silent
[ -n "$SILENT" ] && exec 1>&3 2>&4

# Run container
docker run -it --rm "$TAG"
