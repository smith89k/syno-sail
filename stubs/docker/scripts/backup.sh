#!/bin/sh
set -e

# Load .env file
if [ -f "../../.env" ]; then
    . ../../.env
fi

CONTAINER_NAME="${CONTAINER_NAME:-laravel}"
DB_DATABASE="${DB_DATABASE:-laravel}"
DEPLOY_PATH="${DEPLOY_PATH:-$(pwd)}"
BACKUP_DIR="${DEPLOY_PATH}/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

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
