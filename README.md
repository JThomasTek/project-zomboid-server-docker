# Project Zomboid Docker

## Description

This simple Dockerfile can be used to quickly configure a Project Zomboid dedicated server. Please review the information below for more information on how to run the image.

## Docker Run Flags to Set

| Flag | Value | Description |
|------|-------|-------------|
| --name | <container_name> | Give the running container a name to make it easier to identify. |
| --restart | always | Make sure to start up the container again if it crashes or the machine is restarted. |
| -e | PZ_SERVER_NAME=<server_name> | This will set the name of the server |
| -e | PZ_ADMIN_PASSWORD=<admin_password> | This sets the admin password for the server. As long as the volume mount flag below is set then this is only needed the first time the image is run. |
| -v | <local_path_or_volume>:/home/steam | Sets the persistent storage for the server files and save files. |
| -p | <local_port>:8766/udp | Sets the local port to forward to the 8766 port. Don't forget the `/udp` or else the server may not be reachable. |
| -p | <local_ports>:16261-16262/udp | Sets the local port range to forward to the 16261-16262 port range. Don't forget the `/udp` or else the server may not be reachable. |
