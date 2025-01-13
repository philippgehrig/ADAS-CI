FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    tftpd-hpa \
    nfs-kernel-server \
    isc-dhcp-server \
    xinetd \
    && apt-get clean

RUN mkdir -p /var/lib/tftpboot /exports /etc/dhcp

COPY tftp/tftpd-hpa /etc/default/tftpd-hpa
COPY nfs/exports /etc/exports
COPY dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 69/udp 2049/tcp 67/udp

ENTRYPOINT ["/entrypoint.sh"]
