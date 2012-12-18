#!/bin/sh
# Script take from http://vstone.eu/reducing-vagrant-box-size/
# Copyright Jan Vansteenkiste Jan@vStone.eu
# Modified by Michael Starke michael.starke@hicknhack-software.com
#

cat - << EOWARNING
WARNING: This script will fil up your left over disk space.
 
DO NOT RUN THIS WHEN YOUR VIRTUAL HD IS RAW!!!!!!
 
You should NOT do this on a running system.
This is purely for making vagrant boxes damn small.
 
Press Ctrl+C within the next 10 seconds if you want to abort!!
 
EOWARNING
sleep 10;

echo 'Cleaning apt cache'
apt-get clean

echo 'Purging unused packages'
aptitude purge ri
# sudo aptitude purge installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide
# sudo aptitude purge python-dbus libnl1 python-smartpm linux-headers-2.6.32-21-generic python-twisted-core libiw30
# sudo aptitude purge python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl libffi5

 
echo 'Cleanup bash history'
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history
 
echo 'Cleanup log files'
find /var/log -type f | while read f; do echo -ne '' > $f; done;
 
echo 'Whiteout root'
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`; 
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;
 
echo 'Whiteout /boot'
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;
 
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;