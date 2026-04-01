# Use the official Frappe Bench image as the base
FROM frappe/bench:latest

USER frappe
WORKDIR /home/frappe

# Initialize a new bench and install core apps
RUN bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench && \
    cd /home/frappe/frappe-bench && \
    bench get-app erpnext --branch version-15 && \
    bench get-app https://github.com/frappe/hrms.git hrms

# Copy our rebranded Munafa code into the hrms app folder (overriding the clone)
COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/hrms

# Set up the production site config
WORKDIR /home/frappe/frappe-bench

# Expose ports for web and socketio
EXPOSE 8000
EXPOSE 9000

# Start the bench
CMD ["bench", "start"]
