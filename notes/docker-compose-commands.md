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