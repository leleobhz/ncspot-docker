FROM rust:slim-bullseye as builder

WORKDIR /opt

ARG TAG=v0.11.0

RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt -y install git libncursesw5-dev libdbus-1-dev libpulse-dev libssl-dev libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev \
 && git clone --depth=1 --single-branch --branch=${TAG} https://github.com/hrkfdn/ncspot.git \
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

RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends --yes locales locales-all ca-certificates pulseaudio-utils libxcb-shape0 libxcb-xfixes0 libncursesw6 /opt/*.deb \
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

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY pulse-client.conf /etc/pulse/client.conf

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER $UNAME
ENV HOME /home/${UNAME}

ENTRYPOINT [ "/tini", "--" ] 
CMD [ "ncspot" ]
