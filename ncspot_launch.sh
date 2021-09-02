#!/usr/bin/env bash

echo "Searching for Docker image ..."
DOCKER_IMAGE_ID=$(docker images --format="{{.ID}}" docker-ncspot:latest | head -n 1)
echo "Found and using ${DOCKER_IMAGE_ID}"

USER_UID=$(id -u)

mkdir -p /home/leonardo/.config/ncspot/
mkdir -p /home/leonardo/.cache/ncspot/

docker run --name ncspot --rm -it \
  -e TERM \
  -e LANG \
  -e LC_ALL \
  -e LANGUAGE \
  -e "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus" \
  -e "PULSE_SERVER=unix:/run/pulse/native" \
  --volume="/run/user/${USER_UID}/pulse:/run/pulse" \
  --volume="/run/user/${USER_UID}/bus:/run/dbus" \
  --volume="${HOME}/.config/pulse/:/home/ncspot/.config/pulse/" \
  --volume="${HOME}/.config/ncspot/:/home/ncspot/.config/ncspot/" \
  --volume="${HOME}/.cache/ncspot/:/home/ncspot/.cache/ncspot/" \
  ${DOCKER_IMAGE_ID} \
  ${@}
