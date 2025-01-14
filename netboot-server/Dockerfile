FROM ubuntu:latest

# Set the non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add a specific mirror to the sources.list
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://us.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

# Update the package list and install required packages
RUN apt-get update && \
    apt-get install -y \
    tftpd-hpa \
    nfs-kernel-server \
    isc-dhcp-server \
    xinetd \
    rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/tftpboot /exports/rootfs/jetson-orin /exports/rootfs/raspberry-pi /etc/dhcp && \
    chown -R tftp:tftp /var/lib/tftpboot && \
    chmod -R 755 /exports/rootfs && \
    chown -R nobody:nogroup /exports/rootfs

COPY tftp/tftpd-hpa /etc/default/tftpd-hpa
COPY nfs/exports /etc/exports
COPY dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY create-rootfs.sh /create-rootfs.sh

RUN chmod +x /docker-entrypoint.sh /create-rootfs.sh

# Verify the file is copied correctly
RUN ls -l /docker-entrypoint.sh /create-rootfs.sh

EXPOSE 69/udp 2049/tcp 67/udp

# Run the script to create the root filesystem
RUN /create-rootfs.sh

CMD [ "bin/bash" ]