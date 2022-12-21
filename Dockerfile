FROM docker.io/ubuntu:22.04

ENV PZ_SERVER_NAME="MyPZServer"
# DO NOT USE THIS PASSWORD. PLEASE PROVIDE A SECURE PASSWORD USING
# THE -e FLAG TO THE DOCKER RUN COMMAND.
ENV PZ_ADMIN_PASSWORD="InsecurePassword"

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
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

###################################################################################################

RUN useradd -m -s /bin/bash steam

COPY ./bootstrap /usr/local/sbin/bootstrap

USER steam

RUN steamcmd +quit 

EXPOSE 8766/udp
EXPOSE 16261/udp
EXPOSE 16262/udp

CMD [ "/usr/local/sbin/bootstrap" ]