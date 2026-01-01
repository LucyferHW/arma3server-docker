FROM --platform=$BUILDPLATFORM cm2network/steamcmd:root

ENV DEBIAN_FRONTEND=noninteractive

# Install UTF-8 unicode
RUN echo "**** Install UTF-8 ****" \
    && apt-get update \
    && apt-get install -y locales apt-utils debconf-utils \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

## Upgrade Ubuntu
RUN echo "**** apt upgrade ****" \
    && dpkg --add-architecture i386 \
    && apt-get update; \
    apt-get upgrade -y

## Install Requirements
RUN echo "**** Install Requirements ****" \
    && apt-get update \
    && apt-get install -y software-properties-common \
    && apt-get update \
    && apt-get install -y \
    bc binutils bsdmainutils bzip2 \
    ca-certificates cron cpio curl \
    distro-info file gzip hostname jq \
    lib32stdc++6 lib32gcc-s1 libsdl2-2.0-0:i386 \
    netcat-openbsd pigz python3 \
    tar tmux unzip util-linux \
    wget xz-utils \
    iproute2 iputils-ping nano sudo tini \
    tree uuid-runtime procps grep

# RUN add-apt-repository multiverse
# p7zip-full dos2unix rsync lsof procps iproute2 iputils-ping tzdata procps iproute2 util-linux coreutils bc netcat lib32gcc1

# Install Cleanup
RUN echo "**** Cleanup ****"  \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Arma3-User anlegen
ARG USERNAME=arma3server
ARG UID=1001
ARG GID=1001
RUN groupadd -g ${GID} ${USERNAME} || true \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

# create /etc/arma3 dir
RUN mkdir -p "/etc/arma3" \
    && chown -R ${USERNAME}:${USERNAME} "/etc/arma3"

WORKDIR /home/${USERNAME}
USER ${USERNAME}

ARG SERVER_NAME=base
ARG SCRIPT="/etc/arma3/scripts"
ARG DEFAULT_CONFIG="/etc/arma3/default-config"
ARG LGSM_CONFIG="/home/arma3server/lgsm/config-lgsm/arma3server"
ARG SERVER_CONFIG="/home/arma3server/serverfiles/cfg"
ARG MODPACK_NAME="./arma3server-html/GTO_Base_Base.html"

#copy firstrun file
COPY --chown=${USERNAME}:${USERNAME} scripts/.firstrun ${SCRIPT}/

# copy scripts
COPY --chown=${USERNAME}:${USERNAME} scripts/* ${SCRIPT}/
RUN chmod +x ${SCRIPT}/*

# Zurück zum installieren
RUN curl -Lo linuxgsm.sh https://linuxgsm.sh && \
    chmod +x linuxgsm.sh && \
    bash linuxgsm.sh arma3server

# copy lgsm-configs
RUN mkdir -p ${LGSM_CONFIG}
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/common.cfg ${LGSM_CONFIG}
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/secrets-common.cfg ${LGSM_CONFIG}
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/secrets-arma3server.cfg ${LGSM_CONFIG}

# copy server-configs
RUN mkdir -p ${SERVER_CONFIG}
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/arma3server.server.cfg ${SERVER_CONFIG}
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/arma3server.network.cfg ${SERVER_CONFIG}

# copy userconfig
RUN mkdir -p "/home/arma3server/serverfiles/userconfig"
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/cba_settings.sqf "/home/arma3server/serverfiles/userconfig/"

# copy Profile
RUN mkdir -p "/home/arma3server/.local/share/Arma 3 - Other Profiles/Player"
COPY --chown=${USERNAME}:${USERNAME} arma3server-config/${SERVER_NAME}/Player.Arma3Profile "/etc/arma3/"
RUN mv "/etc/arma3/Player.Arma3Profile" -t '/home/arma3server/.local/share/Arma 3 - Other Profiles/Player'/

# copy html
COPY --chown=${USERNAME}:${USERNAME} ./arma3server-html/${MODPACK_NAME} ${DEFAULT_CONFIG}/
RUN sh -c 'echo "**** HTML Check ****"; ls /etc/arma3/default-config/*.html >/dev/null 2>&1 || { echo "FEHLER: Keine HTML-Datei in /app/config gefunden" >&2; exit 1; }'

# create mpmission directorie
RUN mkdir -p /home/arma3server/serverfiles/mpmissions \
    && chown -R ${USERNAME}:${USERNAME} "/home/arma3server"

ENTRYPOINT ["bash","/etc/arma3/scripts/entrypoint.sh"]

#####

# mount /home/arma3server/serverfiles/mpmissions done
# mount /home/arma3server/serverfiles/userconfig copy -
# todo: mount-virtual mods
# todo: mount-virtual Profiles maybe?

# todo: for userconfig make a git repo that will be pulled on container start (ask S3v1 for help and best practice)