# Project Zomboid Server Docker

The goal of this Docker image is to make it very easy to spin up a dedicated server for Project Zomboid and make sure it stays up to date. A lot of the inspiration for this project came from the awesome work done in the [valheim-server-docker](https://github.com/lloesche/valheim-server-docker) project. Over time I plan to add many of the features available there such as automated backups. Please be sure to check out that project if you are looking to host a Valheim server! 🎮

## Table of Contents

- [Project Zomboid Server Docker](#project-zomboid-server-docker)
  - [Table of Contents](#table-of-contents)
  - [TL;DR](#tldr)
    - [Docker Hub Image](#docker-hub-image)
    - [GHCR Image](#ghcr-image)
    - [NOTE](#note)
  - [Environment Variables](#environment-variables)
    - [Project Zomboid Server Variables](#project-zomboid-server-variables)
    - [Java Variables](#java-variables)
    - [Steam Variables](#steam-variables)
    - [Backup Variables](#backup-variables)
  - [Docker Run Flags](#docker-run-flags)
  - [Docker Compose](#docker-compose)
  - [How the Container Works](#how-the-container-works)
  - [Backups](#backups)
  - [Modifying Server Configuration](#modifying-server-configuration)
    - [Server Config](#server-config)
    - [Sandbox Options](#sandbox-options)

## TL;DR

For those who just want to get a server up and running use the commands below:

### Docker Hub Image

```bash
# Create a data directory to mount persistent data to.
$ mkdir -p $HOME/pz-server

# Set PZ_ADMIN_PASSWORD to something more secure!!! You've been warned!
$ docker run -d \
    --name pzserver \
    -p 8766:8766/udp \
    -p 16261-16262:16261-16262/udp \
    -v $HOME/pz-server:/home/ubuntu \
    -e PZ_ADMIN_PASSWORD="MySecurePassword" \
    jthomastek/project-zomboid-server
```

### GHCR Image

```bash
# Create a data directory to mount persistent data to.
$ mkdir -p $HOME/pz-server

# Set PZ_ADMIN_PASSWORD to something more secure!!! You've been warned!
$ docker run -d \
    --name pzserver \
    -p 8766:8766/udp \
    -p 16261-16262:16261-16262/udp \
    -v $HOME/pz-server:/home/ubuntu \
    -e PZ_ADMIN_PASSWORD="MySecurePassword" \
    ghcr.io/jthomastek/project-zomboid-server
```

### NOTE

Keep in mind, the first time you run the container it can take a minute or two for the server to fully start as the steamcmd client is downloading the server files. Following runs should start up quickly as long as there has not been an update to the server.

## Environment Variables

Variable names and values are case-sensitive.

### Project Zomboid Server Variables

| Name | Default Value | Purpose |
|------|---------------|---------|
| `PZ_SERVER_NAME` | `MyPZServer` | Name of the server that will show in server browsers |
| `PZ_ADMIN_USERNAME` | `admin` | Username of the admin account |
| `PZ_ADMIN_PASSWORD` | `InsecurePassword` | Password that will be used for administrating the server. It is your responsibility to set this to something more secure! |

### Java Variables

| Name | Default Value | Purpose |
|------|---------------|---------|
| `PZ_JAVA_XMS` | `4g` | Sets the minimum amount of memory to allocate to the JVM |
| `PZ_JAVA_XMX` | `8g` | Sets the maximum amount of memory to allocate to the JVM |

### Steam Variables

| Name | Default Value | Purpose |
|------|---------------|---------|
| `PZ_STEAM_VAC` | `true` | Enables or disables [Valve Anti-Cheat](https://en.wikipedia.org/wiki/Valve_Anti-Cheat) on the server |

### Backup Variables

| Name | Default Value | Purpose |
|------|---------------|---------|
| `PZ_BACKUP_ENABLED` | `false` | Enables periodic backups when set to `true` |
| `PZ_BACKUP_INTERVAL` | `3600` | Seconds between backups |
| `PZ_BACKUP_RETENTION` | `10` | Number of most recent backups to keep |
| `PZ_BACKUP_DIR` | `/home/ubuntu/backups` | Directory where backups are stored |
| `PZ_BACKUP_TARGET` | `/home/ubuntu/Zomboid` | Directory to back up |

## Docker Run Flags

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

## Docker Compose

Below is a Docker Compose example that can be used to deploy your Project Zomboid server. The rcon service is optional but will use the [itzg/rcon](https://hub.docker.com/r/itzg/rcon/) image to provide a web admin tool for rcon. The `itzg/rcon` image uses the [rcon-web-admin](https://github.com/rcon-web-admin/rcon-web-admin) project where you can find additional details for configuring RCON Web Admin.

```yaml
services:
  # The rcon service is optional. If you do not wish to use RCON Web Admin you can remove the rcon section.
  rcon:
    image: itzg/rcon
    environment:
      RWA_USERNAME: admin
      RWA_PASSWORD: ${RWA_PASS} # Provided via an environment variable
      RWA_ADMIN: "TRUE"
      # is referring to the hostname of 'pz' compose service below
      RWA_RCON_HOST: pz
      # needs to match the RCONPassword configured in your PZ server ini file
      RWA_RCON_PASSWORD: ${RCON_PASS} # Provided via an environment variable
      RWA_GAME: "project-zomboid"
      RWA_SERVER_NAME: "MyPZServer"
      RWA_RCON_PORT: 27015
    ports:
      - "4326-4327:4326-4327"
  pz: 
    image: jthomastek/project-zomboid-server
    environment:
      PZ_SERVER_NAME: "MyPZServer"
      PZ_ADMIN_USERNAME: "admin"
      PZ_ADMIN_PASSWORD: "MySecurePassword" # Set this to something more secure!!! You've been warned!
      PZ_JAVA_XMS: "4g" # Make sure to allocate enough memory or the server will not start
      PZ_JAVA_XMX: "8g"
      PZ_STEAM_VAC: "true"
      PZ_BACKUP_ENABLED: "true"
      PZ_BACKUP_INTERVAL: "3600"
      PZ_BACKUP_RETENTION: "10"
    volumes: 
      - ${HOME}/pz-server:/home/ubuntu # You can instead use a docker volume with pz-server:/home/ubuntu but this will make it more difficult to update server configuration later
    ports:
      - "8766:8766/udp"
      - "16261-16262:16261-16262/udp"
    restart: unless-stopped
    stop_grace_period: 1m
```

## How the Container Works

When this container is run it will call the [bootstrap](bootstrap) script. This script first checks if the `/home/ubuntu/Zomboid` directory exists. This is done to determine how to run the server start script later on.

Next the bootstrap script will attempt to install/update the Project Zomboid server.

Finally, the server startup script will run.

## Backups

When `PZ_BACKUP_ENABLED` is set to `true`, the container will create a tar.gz backup of the `PZ_BACKUP_TARGET` directory at the configured interval and store it in `PZ_BACKUP_DIR`. Backups are kept in the same `/home/ubuntu` volume mount so they persist across container restarts.

## Modifying Server Configuration

If you would like to be able to easily modify the server configuration files I recommend mounting a local directory to the container.

The first time you deploy your server it will create all the Project Zomboid server configuration files for you with their default values. Stop the container and then open the directory you mounted as a volume to your container to update the config files.

### Server Config

The server config ini file will be located at `${HOME}/pz-server/Zomboid/Server/MyPZServer.ini` if you used one of the Docker run commands or the Docker Compose shown above. This is where you can add mods to your server and configure RCON. I recommend following the instructions in the [Installing Mods](https://pzwiki.net/wiki/Dedicated_server#Installing_mods) section of the Project Zomboid Wiki if you do wish to install mods.

### Sandbox Options

The sandbox options file is located at `${HOME}/pz-server/Zomboid/Server/MyPZServer_SandboxVars.lua` if you used one of the Docker run commands or the Docker Compose shown above. More information about the sandbox options can be found on the [Custom Sandbox](https://pzwiki.net/wiki/Custom_Sandbox) page of the Project Zomboid wiki. The file is also well commented so this should be pretty easy to update.
