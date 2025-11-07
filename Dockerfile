FROM ubuntu:22.04

# Noninteractive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install redsocks + tools
RUN apt-get update && apt-get install -y \
    redsocks \
    iptables \
    iproute2 \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create redsocks config directory
RUN mkdir -p /etc/redsocks

# Copy template files
COPY redsocks.conf.template /etc/redsocks/redsocks.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
