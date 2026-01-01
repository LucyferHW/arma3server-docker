# Docker Compose Commands

```Bash
docker compose up          # baut nur, wenn noch kein Image existiert

docker compose up --build  # baut auf jeden Fall neu → Standard im Dev

docker compose build       # baut nur die Images, startet nichts

docker compose push        # (nach build) pusht in Registry

docker compose down -v     # löscht auch named volumes
```

## My Docker Compose Commands
```Bash
docker compose -f docker-compose.base.yml up -d --build
docker compose -f docker-compose.main.yml up -d --build
docker compose -f docker-compose.custom.yml up -d --build
```

## Possible Alias
```Bash
# in deine ~/.bashrc oder ~/.zshrc
alias a3up='docker compose -f docker-compose.server1.yml up -d --build'
alias a3down='docker compose -f docker-compose.server1.yml down'
```

## Shortcut Script

```Bash
if [ -z "$1" ]; then
    echo "Fehler: Kein Argument Uebergeben."
    echo "Verwendung: $0 <server-name> <start|stop|up|down|logs>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Fehler: Kein Argument Uebergeben."
    echo "Verwendung: $0 <server-name> <start|stop|up|down|logs>"
    exit 1
fi

SERVER=$1
CMD=$2

sh -c "docker compose -f docker-compose.${SERVER}.yml ${CMD}"

#alias a3up='docker compose -f docker-compose.base.yml up -d'
#alias a3start='docker compose -f docker-compose.base.yml start'
#alias a3stop='docker compose -f docker-compose.base.yml stop'
#alias a3down='docker compose -f docker-compose.base.yml down'
#alias a3logs='docker compose -f docker-compose.base.yml logs -f'
```