#!/bin/bash

# Wait for database and redis to be ready in the cloud
echo "Waiting for services..."
sleep 10

# Initialize site if it doesn't exist
if [ ! -d "sites/hrms.localhost" ]; then
    echo "First time setup: Creating site hrms.localhost..."
    # Connect to the cloud database (Railway uses DB_HOST or DATABASE_URL)
    bench set-postgres-host "${DB_HOST:-db}"
    bench set-redis-cache-host "redis://${REDIS_HOST:-redis}:6379"
    bench set-redis-queue-host "redis://${REDIS_HOST:-redis}:6379"
    bench set-redis-socketio-host "redis://${REDIS_HOST:-redis}:6379"

    bench new-site hrms.localhost \
    --db-type postgres \
    --postgres-root-password "${DB_PASSWORD:-123}" \
    --admin-password "${ADMIN_PASSWORD:-admin}" \
    --force
    
    bench --site hrms.localhost install-app hrms
    bench --site hrms.localhost set-config developer_mode 1
fi

# Start the application
echo "Starting Munafa..."
bench start
