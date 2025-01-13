#!/bin/bash

service tftpd-hpa start
service nfs-kernel-server start
service isc-dhcp-server start
exportfs -a
tail -f /dev/null
