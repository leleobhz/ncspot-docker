#!/usr/bin/env bash

mytitle="Spotify"
echo -e '\033]2;'$mytitle'\007'

echo "Searching for Docker image ..."
DOCKER_IMAGE_ID=$(docker images --format="{{.ID}}" docker-ncspot:latest | head -n 1)

if [[ ! $DOCKER_IMAGE_ID ]]; then
	echo Image not found. Building one.
	./build.sh
else
	echo "Found and using ${DOCKER_IMAGE_ID}"
fi

USER_UID=$(id -u)

mkdir -p /home/leonardo/.config/ncspot/
mkdir -p /home/leonardo/.cache/ncspot/

podman run --name ncspot --rm -it \
  --user ${USER_UID} \
  --userns keep-id \
  -e TERM \
  -e LANG \
  -e LC_ALL \
  -e LANGUAGE \
  -e DISPLAY \
  -e "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus" \
  -e "PULSE_SERVER=unix:/run/pulse/native" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
  --volume="/run/user/${USER_UID}/pulse:/run/pulse" \
  --volume="/run/user/${USER_UID}/bus:/run/dbus" \
  --volume="${HOME}/.config/pulse/:/home/ncspot/.config/pulse/:Z" \
  --volume="${HOME}/.config/ncspot/:/home/ncspot/.config/ncspot/:Z" \
  --volume="${HOME}/.cache/ncspot/:/home/ncspot/.cache/ncspot/:Z" \
  docker-ncspot:latest \
  ${@}
