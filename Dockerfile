# Use the official Frappe Bench image as the base
FROM frappe/bench:latest

USER frappe
WORKDIR /home/frappe

# Initialize a new bench and install core apps. 
# Optimized: Remove .git folders and clean caches to reduce image size.
RUN bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench && \
    cd /home/frappe/frappe-bench && \
    bench get-app erpnext --branch version-15 && \
    bench get-app https://github.com/frappe/hrms.git hrms && \
    find apps -name ".git" -type d -exec rm -rf {} + && \
    rm -rf ~/.cache/pip ~/.npm

# Copy our rebranded Munafa code into the hrms app folder (overriding the clone)
COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/hrms

WORKDIR /home/frappe/frappe-bench

# Optimized: Build hrms specifically to compile Munafa assets
RUN bench build --app hrms && \
    rm -rf ~/.cache/pip ~/.npm

# Move the entrypoint script
COPY --chown=frappe:frappe entrypoint.sh /home/frappe/frappe-bench/entrypoint.sh
RUN chmod +x /home/frappe/frappe-bench/entrypoint.sh

# Expose ports for web and socketio
EXPOSE 8000 9000

# Start the entrypoint script
CMD ["/bin/bash", "/home/frappe/frappe-bench/entrypoint.sh"]
