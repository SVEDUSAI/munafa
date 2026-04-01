#!/bin/bash
set -e

# Wait for database and redis to be ready in the cloud
echo "Waiting for services..."
sleep 15

# Railway environment variables
DB_HOST=${PGHOST:-${DB_HOST:-db}}
DB_PASSWORD=${PGPASSWORD:-${DB_PASSWORD:-123}}
REDIS_HOST=${REDISHOST:-${REDIS_HOST:-redis}}

# Initialize site if it doesn't exist
if [ ! -d "sites/hrms.localhost" ]; then
    echo "First time setup: Creating site hrms.localhost..."
    # Connect to the cloud database
    bench set-postgres-host "$DB_HOST"
    bench set-redis-cache-host "redis://$REDIS_HOST:6379"
    bench set-redis-queue-host "redis://$REDIS_HOST:6379"
    bench set-redis-socketio-host "redis://$REDIS_HOST:6379"

    bench new-site hrms.localhost \
    --db-type postgres \
    --postgres-root-password "$DB_PASSWORD" \
    --admin-password "${ADMIN_PASSWORD:-admin}" \
    --force
    
    # Install Munafa (hrms) and ERPNext
    echo "Installing apps..."
    bench --site hrms.localhost install-app erpnext
    bench --site hrms.localhost install-app hrms
fi

# Re-branding and Production mode
bench --site hrms.localhost set-config developer_mode 0
bench --site hrms.localhost set-config show_progress_bar 0

# Verify and build hrms assets
echo "Building assets..."
bench build --app hrms

# Start Munafa
echo "Starting Munafa with bench start..."
bench start
