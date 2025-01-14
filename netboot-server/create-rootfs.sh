#!/bin/sh

# Seriennummer des Raspberry Pi
SERIALNUM="32373e31"

# Erstellen des Root-Dateisystems für Raspberry Pi
echo "Erstellen des Root-Dateisystems für Raspberry Pi..."
mkdir -p /exports/rootfs/$SERIALNUM
rsync -xa --progress --exclude /exports / /exports/rootfs/$SERIALNUM

# SSH-Schlüssel löschen und SSH aktivieren
echo "SSH-Schlüssel löschen und SSH aktivieren..."
cd /exports/rootfs/$SERIALNUM
mount --bind /dev dev
mount --bind /sys sys
mount --bind /proc proc
chroot . rm -f /etc/ssh/ssh_host_*
chroot . dpkg-reconfigure openssh-server
chroot . systemctl enable ssh
sleep 1
umount dev sys proc
touch boot/ssh

# Konfigurieren von /etc/fstab für den Client
echo "Konfigurieren von /etc/fstab für den Client..."
echo | tee /exports/rootfs/$SERIALNUM/etc/fstab
echo "proc /proc proc defaults 0 0" | tee -a /exports/rootfs/$SERIALNUM/etc/fstab
echo "192.168.1.45:/tftpboot /boot nfs defaults,vers=4.1,proto=tcp 0 0" | tee -a /exports/rootfs/$SERIALNUM/etc/fstab

# Exportieren des Root-Dateisystems und des TFTP-Boot-Ordners
echo "Exportieren des Root-Dateisystems und des TFTP-Boot-Ordners..."
echo "/exports/rootfs/$SERIALNUM *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports
echo "/tftpboot *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports

# Vorbereiten des TFTP-Boot-Ordners
echo "Vorbereiten des TFTP-Boot-Ordners..."
mkdir -p /var/lib/tftpboot/$SERIALNUM
chmod 777 /var/lib/tftpboot
cp -r /boot/* /var/lib/tftpboot/$SERIALNUM
cp /boot/bootcode.bin /var/lib/tftpboot/

# Konfigurieren von cmdline.txt
echo "Konfigurieren von cmdline.txt..."
echo "console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=192.168.1.45:/exports/rootfs/$SERIALNUM,vers=4.1,proto=tcp rw ip=dhcp rootwait" | tee /var/lib/tftpboot/$SERIALNUM/cmdline.txt
chmod 777 /var/lib/tftpboot/$SERIALNUM/cmdline.txt

echo "Root-Dateisystem und TFTP-Boot-Ordner erfolgreich erstellt und konfiguriert."