#!/bin/bash
set -e

FIRST_RUN_MARKER="/etc/arma3/scripts/.firstrun"

DEFAULT_CONFIG="/etc/arma3/default-config"
LGSM_CONFIG="/home/arma3server/lgsm/config-lgsm/arma3server"

SCRIPTS="/etc/arma3/scripts"

HTML_PATH="/etc/arma3/"
MOD_LIST="/etc/arma3/scripts/sub_list.txt"
MOD_DIRECTORY="/home/arma3server/.local/share/Steam/steamapps/workshop/content/107410"

if [ -f "$FIRST_RUN_MARKER" ]; then
    echo ""
    echo "== First start =="

    # import steam user and password
    export STEAMUSER="$(cat /run/secrets/steam_user)"
    export STEAMPASS="$(cat /run/secrets/steam_password)"
    printf 'steamuser="%s"\nsteampass="%s"\n' "${STEAMUSER}" "${STEAMPASS}" > "${LGSM_CONFIG}/secrets-common.cfg"

    # install Arma 3
    bash arma3server auto-install

    # setup and download mods
    bash ${SCRIPTS}/create_sublist.sh "${HTML_PATH}" "${MOD_LIST}"
    bash ${SCRIPTS}/set_modlist.sh "${HTML_PATH}" "${LGSM_CONFIG}/secrets-arma3server.cfg"
    #bash ${SCRIPTS}/download_mods.sh "/home/steam/steamcmd/steamcmd.sh" "${MOD_LIST}" "${STEAMUSER}" "${STEAMPASS}"
    #bash ${SCRIPTS}/fix_mods_lowercase.sh ${MOD_DIRECTORY}

    # link mods dir to serverfiles (for shorter paths)
    mkdir -p "/home/arma3server/serverfiles"
    ln -s ${MOD_DIRECTORY} "/home/arma3server/serverfiles/mods"

    echo ""
    echo "=== First run completed ==="

    # Marker-Datei löschen -> nächster Start ist kein First-Run mehr
    rm -f "$FIRST_RUN_MARKER"
else
    echo ""
    echo "== Regular start =="
fi

    # === 1. Sauberes Herunterfahren bei Docker-Stop ===
    cleanup() {
        echo "SIGTERM/SIGINT erhalten → stoppe Arma 3 Server..."
        ./arma3server stop || true
        sleep 30
        exit 0
    }
    trap cleanup SIGTERM SIGINT

    # === 2. Server starten – WICHTIG: im Vordergrund! ===
    echo "Starte Arma 3 Server..."
    ./arma3server start

    # === 3. Jetzt einfach laufen lassen ===
    # Normaler Container-Betrieb: zeige Logs + halte Container am Leben
    echo "Server läuft – folge den Logs (Strg+C zum Beenden → Server wird sauber gestoppt)"
    tail -f /home/arma3server/log/script/*.log /home/arma3server/log/console/*.log 2>/dev/null || true &

    # WICHTIG: Dieser Prozess muss am Leben bleiben!
    # Docker schickt SIGTERM an PID 1 → unser trap fängt es ab
    wait