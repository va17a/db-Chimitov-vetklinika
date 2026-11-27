#!/usr/bin/env bash
set -euo pipefail

# Запускать из корня проекта после cp .env.example .env и docker compose up -d.
BACKUP_FILE="${1:-backup.dump}"
DB_USER="${POSTGRES_USER:-postgres}"
SOURCE_DB="${POSTGRES_DB:-app}"
RESTORE_DB="app_restore_check"

cleanup() {
    docker compose exec -T db psql -U "$DB_USER" -d postgres \
        -c "DROP DATABASE IF EXISTS $RESTORE_DB WITH (FORCE);" >/dev/null
}
trap cleanup EXIT

# Снять дамп в формате custom и восстановить его в отдельную чистую базу.
docker compose exec -T db pg_dump -U "$DB_USER" -d "$SOURCE_DB" -Fc > "$BACKUP_FILE"
cleanup
docker compose exec -T db createdb -U "$DB_USER" "$RESTORE_DB"
docker compose exec -T db pg_restore -U "$DB_USER" -d "$RESTORE_DB" \
    --no-owner --no-privileges < "$BACKUP_FILE"

# Проверить, что основные данные восстановлены.
docker compose exec -T db psql -U "$DB_USER" -d "$RESTORE_DB" \
    -c "SELECT (SELECT count(*) FROM pets) AS pets, (SELECT count(*) FROM visits) AS visits, (SELECT count(*) FROM visit_procedures) AS visit_procedures;"

printf 'Резервная копия сохранена: %s\nПроверка восстановления завершена успешно.\n' "$BACKUP_FILE"
