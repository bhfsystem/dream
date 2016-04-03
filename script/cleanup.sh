#!/usr/bin/env bash -eux

CLEANUP_PAUSE=${CLEANUP_PAUSE:-0}
echo "==> Pausing for ${CLEANUP_PAUSE} seconds..."
sleep ${CLEANUP_PAUSE}

# virtualbox
rm -f ~ubuntu/VBoxGuestAdditions.iso || true

# Make sure udev does not block our network - http://6.ptmc.org/?p=164
echo "==> Cleaning up udev rules"
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

echo "==> Cleaning up leftover dhcp leases"
rm -f /var/lib/dhcp/*

# Add delay to prevent "vagrant reload" from failing
if [[ -f /etc/network/interfaces.d/eth0.cfg ]]; then
  # this works on aws
  echo "pre-up sleep 2" >> /etc/network/interfaces.d/eth0.cfg
else
  echo "pre-up sleep 2" >> /etc/network/interfaces
fi

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

echo "==> Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync
