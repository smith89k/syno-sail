#!/bin/sh
set -e

MAX_RETRIES=30
RETRY_INTERVAL=3

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
RETRY_COUNT=0
until php -r '
try {
    $dsn = sprintf("mysql:host=%s;port=%s", getenv("DB_HOST"), getenv("DB_PORT"));
    new PDO($dsn, getenv("DB_USERNAME"), getenv("DB_PASSWORD"));
    echo "connected";
} catch (PDOException $e) {
    exit(1);
}
' 2>/dev/null; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Database not available after ${MAX_RETRIES} retries."
        exit 1
    fi
    echo "Database not ready (attempt ${RETRY_COUNT}/${MAX_RETRIES}), retrying in ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
done
echo "Database is ready."

php artisan migrate --force --no-interaction

php artisan config:cache
php artisan route:cache
php artisan view:cache

exec "$@"
