# Project Zomboid Server Docker

The goal of this Docker image is to make is very easy to spin up a dedicated server for Project Zomboid and make sure it stays up to date. A lot of the inspiration for this project came from the awesome work done in the [valheim-server-docker](https://github.com/lloesche/valheim-server-docker) project. Over time I plan to add many of the features available there such as automated backups. Please be sure to check out that project if you are looking to host a Valheim server! 🎮

# Table of Contents

- [TL;DR](#tldr)
- [Environment Variables](#environment-variables)
- [Docker Run Flags](#docker-run-flags)
- [How the Container Works](#how-the-container-works)

# TL;DR

For those who just want to get a server up and running use the commands below:

```bash
# Create a data directory to mount persistent data to.
$ mkdir -p $HOME/pz-server
# The first time you run this command provide the flag '-e PZ_ADMIN_PASSWORD=<admin_password>'. In following runs this flag can be omitted as long as the same volume mount is used.
$ docker run -d \
    --name pzserver \
    -p 8766:8766/udp \
    -p 16261-16262:16261-16262/udp \
    -v $HOME/pz-server:/home/steam \
    -e PZ_SERVER_NAME="MyPZServer" \
    -e PZ_ADMIN_PASSWORD="MySecurePassword" \
    jthomastek/project-zomboid-server
```

Keep in mind, the first time you run the container it can take a minute or two for the server to fully start as the steamcmd client is downloading the server files. Following runs should start up quickly as long as there has not been an update to the server.

# Environment Variables

Variable names and values are case-sensitive.

| Name | Default Value | Purpose |
|------|---------------|---------|
| `PZ_SERVER_NAME` | `MyPZServer` | Name of the server that will show in server browsers |
| `PZ_ADMIN_PASSWORD` | `InsecurePassword` | Password that will be used for administrating the server. It is your responsibility to set this to something more secure! |

# Docker Run Flags

The following table lists the recommended flags to be used with the `docker run` command.

| Flag | Value | Description |
|---------|-----------|-------------|
| --name | <container_name> | Give the running container a name to make it easier to identify. |
| -p | <local_port>:8766/udp | Sets the local port to forward to the 8766 port. Don't forget the `/udp` or else the server may not be reachable. |
| -p | <local_ports>:16261-16262/udp | Sets the local port range to forward to the 16261-16262 port range. Don't forget the `/udp` or else the server may not be reachable. |
| -v | <local_path_or_volume>:/home/steam | Sets the persistent storage for the server files and save files. |
| -e | PZ_SERVER_NAME=<server_name> | This will set the name of the server |
| -e | PZ_ADMIN_PASSWORD=<admin_password> | This sets the admin password for the server. As long as the volume mount flag below is set then this is only needed the first time the image is run. |
| --restart | always | Make sure to start up the container again if it crashes or the machine is restarted. |

# How the Container Works

When this container is run it will call the [bootstrap](bootstrap) script. This script first checks if the `/home/steam/Zomboid` directory exists. This is done to determine how to run the server start script later on.

Next the bootstrap script will attempt to install/update the Project Zomboid server.

Finally, the server startup script is run. If the Zomboid directory **did not** exist before running steamcmd then the `PZ_ADMIN_PASSWORD` variable is passed to the server startup script to fulfill the first time run configuration of the startup script. If the Zomboid directory **did** exist then the admin password will not be passed to the server startup script to help prevent exposing the admin password in the container logs.
