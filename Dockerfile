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

# Move the entrypoint script
WORKDIR /home/frappe/frappe-bench
COPY --chown=frappe:frappe entrypoint.sh /home/frappe/frappe-bench/entrypoint.sh
RUN chmod +x /home/frappe/frappe-bench/entrypoint.sh

# Expose ports for web and socketio
EXPOSE 8000
EXPOSE 9000

# Start the entrypoint script
CMD ["/bin/bash", "/home/frappe/frappe-bench/entrypoint.sh"]
