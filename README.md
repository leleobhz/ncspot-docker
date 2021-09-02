# Docker ncspot

A Docker version of [ncspot](https://github.com/hrkfdn/ncspot/) based on [docker-pulseaudio-example](https://github.com/TheBiggerGuy/docker-pulseaudio-example).

## Features

* NCurses working perfectly
* Pulseaudio working perfectly
* Localization working perfectly (But upstream apparently only provides English)
* DBus passthrough working perfectly
* MPRIS interface working perfectly
* Docker rootless working perfectly

## Screenshot with MPRIS interface

![screenshot-mpris](https://user-images.githubusercontent.com/201189/131779762-65aaee8e-8684-4bc2-8ba2-8f1ab12ade50.png)

## Building
```bash
./build.sh
```

## Running
```bash
./nspot_launch.sh
```

## TO-DO

* Enable SHM to PulseAudio (Maybe? Maybe not?)
* Podman support (Is possible?)
