#!/bin/bash
#
# Swap File Creator
#
# This script will create and configure a swap file
# on your droplet at creation time.
# Tested on:
#  Fedora 22
#  Fedora 23
# 
# There are two modes:
#   * automatic mode
#
#     Based Red Hat Enterprise Linux Administration Guide
#     Swap should equal 2x physical RAM for up to 2 GB of physical RAM,
#     and then an additional 1x physical RAM for any amount above 2 GB,
#     but never less than 32 MB.For more informationm, please visit:
#                                                 https://goo.gl/kFGdnO
#
#     ╔════════════════════════╦═════════════════════════╗
#     ║(M) Amount of RAM in G  ║ (S) Amount of swap in G ║
#     ╠════════════════════════╬═════════════════════════╣
#     ║ M < 2G	               ║ S = M * 2G              ║
#     ╠════════════════════════╬═════════════════════════╣
#     ║ 2G  < M < 32G          ║ S = M + 2G              ║
#     ╠════════════════════════╬═════════════════════════╣
#     ║ 32G < M                ║ S = 32G or S = M        ║
#     ╚════════════════════════╩═════════════════════════╝
# 
#
#   * manual mode
#     * Replace <%SWAP_FILE_SIZE%> with your custom swap size

mode=automatic

function automatic()
{
 min="2147483648"
 max="34359738368"
 echo "Detecting current RAM size..."
 ram_size="$(free -b | grep Mem | awk '{ print $2 }' )"
 echo "... Physical Memory Size: $ram_size"
 echo "Calculating recommended SWAP file size..."
 if [[ $ram_size -le $min ]]
 then
   echo "The RAM size is less than 2G"
   swapsize=$(( $ram_size * 2 ))
   echo "...recommended size: $swapsize"
 elif [[ $ram_size -ge $min ]] && [[ $ram_size -lt $max ]]
 then
   echo "The RAM size is equal to 2G and less than 32GB"
   swapsize=$(( $ram_size + $min ))
   echo "...recommended size: $swapsize"
 elif [[ $ram_size -ge $max ]]
 then
   echo "The RAM size is greater than 32GB"
   swapsize=$max
   echo "...recommended size: $swapsize"
 fi
}

if [[ $mode == automatic ]]
then
  echo "Running automatic mode..."
  automatic
elif [[ $mode == manual ]]
then
  echo "Running on manual mode..."
  swapsize="<%SWAP_FILE_SIZE%>"
fi

fallocate -l $swapsize /swapfile
chmod 600 /swapfile
mkswap /swapfile -L swap
swapon /swapfile
echo "/swapfile   swap    swap    sw    0   0" >> /etc/fstab
