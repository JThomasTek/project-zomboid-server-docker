#!/bin/bash
# Steam update adapter for Project Zomboid dedicated server
# Downloads/updates server files via SteamCMD
#
# Usage: ./update-server.sh [install_dir]
# Exit codes:
#   0 - Success
#   1 - SteamCMD update failed

INSTALL_DIR="${1:-/home/ubuntu/pzserver}"

echo "Updating Project Zomboid server in $INSTALL_DIR"

steamcmd +force_install_dir "$INSTALL_DIR" +login anonymous +app_update 380870 +quit
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "SteamCMD update failed with exit code $EXIT_CODE" >&2
    exit 1
fi

echo "Server files updated successfully"
exit 0
