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
    xinetd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/tftpboot /exports /etc/dhcp

COPY tftp/tftpd-hpa /etc/default/tftpd-hpa
COPY nfs/exports /etc/exports
COPY dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

RUN ls -l /docker-entrypoint.sh

EXPOSE 69/udp 2049/tcp 67/udp

ENTRYPOINT ["/docker-entrypoint.sh"]