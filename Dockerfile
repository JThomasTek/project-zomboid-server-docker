FROM ubuntu:24.04

# Project Zomboid server parameters
ENV PZ_SERVER_NAME="MyPZServer"
ENV PZ_ADMIN_USERNAME="admin"
# DO NOT USE THIS PASSWORD. PLEASE PROVIDE A SECURE PASSWORD USING
# THE -e FLAG TO THE DOCKER RUN COMMAND.
ENV PZ_ADMIN_PASSWORD="InsecurePassword"

# Java parameters
ENV PZ_JAVA_XMS="4g"
ENV PZ_JAVA_XMX="8g"

# Steam parameters
ENV PZ_STEAM_VAC="true"

# Backup parameters
ENV PZ_BACKUP_ENABLED="false"
ENV PZ_BACKUP_INTERVAL="3600"
ENV PZ_BACKUP_RETENTION="10"
ENV PZ_BACKUP_DIR="/home/ubuntu/backups"
ENV PZ_BACKUP_TARGET="/home/ubuntu/Zomboid"

##################### Commands Copied From GitHub.com/steamcmd/docker Project #####################
# Original code Copyright (c) 2020 Jona Koudijs (https://github.com/jonakoudijs)

# Licensed under the MIT License

# URL: https://github.com/steamcmd/docker

# This is used to install the steamcmd client. Original code can be found here:
# https://github.com/steamcmd/docker/blob/0de8673ef2fa3a9ad4eba686dfe019c0e792cded/dockerfiles/ubuntu-20/Dockerfile#L13-L31

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates locales steamcmd && \
    rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

###################################################################################################

COPY ./bootstrap /usr/local/sbin/bootstrap

WORKDIR /home/ubuntu

USER ubuntu

RUN steamcmd +quit 

EXPOSE 8766/udp
EXPOSE 16261-16262/udp

CMD [ "/usr/local/sbin/bootstrap" ]
