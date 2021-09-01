FROM rust:slim-bullseye as builder

WORKDIR /opt

RUN apt update \
 && apt -y install git libncursesw5-dev libdbus-1-dev libpulse-dev libssl-dev libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev \
 && git clone https://github.com/hrkfdn/ncspot.git \
 && cd ncspot \
 && cargo install cargo-deb \
 && cargo deb \
 && apt -y purge git \
 && cat /var/log/apt/history.log| grep Install: | sed "s/([^)]*)//g" | sed "s,\ \,\ ,\ ,g" | sed "s,Install: ,,g" | xargs apt remove -y \
 && rm -rf /var/cache/apt/lists/* \
 && mv /opt/ncspot/target/debian/*.deb /opt \
 && rm -rf /opt/ncspot

FROM debian:stable-slim

ENV UNAME ncspot

COPY --from=builder /opt/*.deb /opt/

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt install --yes pulseaudio-utils /opt/*.deb \
 && rm -rf /var/cache/apt/lists/*

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

COPY pulse-client.conf /etc/pulse/client.conf

USER $UNAME
ENV HOME /home/${UNAME}

ENTRYPOINT ncspot
