#!/bin/bash
set -e

# Start TFTP
echo "Starting TFTP server..."
service tftpd-hpa start

# Start NFS
echo "Starting NFS server..."
service nfs-kernel-server start

# Start DHCP
echo "Starting DHCP server..."
service isc-dhcp-server start

# Keep the container running
echo "All services started. Logs will be outputted below:"
tail -f /var/log/syslog
