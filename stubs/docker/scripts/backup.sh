#!/bin/sh
set -e

DEPLOY_PATH="${DEPLOY_PATH:-$(pwd)}"

# Load .env file
if [ -f "${DEPLOY_PATH}/.env" ]; then
    # export variables so they are available, or just source them. 
    # 'set -a' exports all variables defined
    set -a
    . "${DEPLOY_PATH}/.env"
    set +a
fi

CONTAINER_NAME="${CONTAINER_NAME:-laravel}"
DB_DATABASE="${DB_DATABASE:-laravel}"

PROJECT_NAME="$(basename "$DEPLOY_PATH")"
BACKUP_DIR="${BACKUP_DIR:-/volume1/docker/backups/${PROJECT_NAME}}"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

# Redirect all output to the backup log
exec >> "$BACKUP_DIR/backup.log" 2>&1

echo "Backing up database..."
docker exec ${CONTAINER_NAME}-db sh -c "mariadb-dump -u root ${DB_DATABASE}" \
  > "$BACKUP_DIR/db_${DATE}.sql"

echo "Backing up storage..."
tar -czf "$BACKUP_DIR/storage_${DATE}.tar.gz" "${DEPLOY_PATH}/data/storage/"

echo "Removing backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -name "db_*.sql" -mtime +${RETENTION_DAYS} -delete
find "$BACKUP_DIR" -name "storage_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

echo "Backup complete:"
ls -lh "$BACKUP_DIR/db_${DATE}.sql" "$BACKUP_DIR/storage_${DATE}.tar.gz"
