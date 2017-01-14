#!/usr/bin/env bash
#
# Swap File Creator
#
# Purpose: This script will create a swap file on your droplet,
#   and configure it to be persistent across reboots.
# 
# Installation: Download swap.sh to your droplet, then make it executable:
#   chmod +x ./swap.sh
#
# Usage: Either input the swap file size followed by the file name as
#   command-line arguments, or you will be prompted to do so at exec time.
#

# Ensures a swap file size and swap file name are passed to the script.
if [ ${#} -ne 2 ]; then
  echo "Please enter the size (in whole GBs) of the new swap file, then press enter: ";
  read req_swap_size;
  echo "Please enter a valid file path for the new swap file, then press enter: ";
  read swap_file_name;
else
  req_swap_size=${1};
  swap_file_name=${2};
fi

# Runs checks on user inputs to ensure swap file name is not in use already.
  if [[ -e "${swap_file_name}" ]]; then
    echo "[ERROR] Swap file path/name already in use.";
    exit 1;
  fi
  
# Runs checks on user inputs to ensure swap file size is valid and disk space is available.
  swap_size=${req_swap_size//[^0-9]};
  if [[ "${#req_swap_size}" != "${#swap_size}" ]]; then
    echo "[ERROR] Invalid swap size of \"${req_swap_size}\" gigabytes requested; use positive whole numbers only."
    exit 1;
  fi
  type df > /dev/null && \
  avail_disk=$(df -B G --output=avail /);
  avail_disk=${avail_disk//[^0-9]};
  if [[ "${avail_disk}" -lt "${swap_size}" ]]; then
    echo "[ERROR] Not enough disk space to create swap file of requested size: ${swap_size}G.";
    exit 1;
  fi
  echo "[INFO] Requested swap size of \"${swap_size}G\" is valid and disk space is available.";
  
# Uses the 'fallocate' binary to create a swap file.
  type fallocate &>/dev/null && \
  fallocate -l ${swap_size}G ${swap_file_name} &>/dev/null;
  if [[ ! -e "${swap_file_name}" ]]; then
    echo "[ERROR] Unable to create ${swap_size}G-sized swap file at location: \"${swap_file_name}\"";
    exit 1;
  fi
  echo "[INFO] Successfully created ${swap_size}G-sized file at location: \"${swap_file_name}\"";
  
# Makes the newly created regular file into a swap file.
  echo "[INFO] Now attempting to change newly created file into a persistent swap file...";
  chmod 600 ${swap_file_name} &>/dev/null && \
  mkswap ${swap_file_name} &>/dev/null && \
  swapon ${swap_file_name} &>/dev/null && \
  echo "${swap_file_name}   none    swap    sw    0   0" >> /etc/fstab;
  
# Show all active swap files/partitions.
  echo "[INFO] All currently active swap files and partitions:";
  while read line; do
    printf "\t$line\n";
  done <<<"$(cat /proc/swaps)"
  
# Tell user the results of the script.
  if [[ "${?}" != "0" ]]; then
    printf "\n[ERROR] Failed to change file \"${swap_file_name}\" into a persistent swap file.\n";
    exit 1;
  else
    printf "\n[INFO] Successfully changed regular file \"${swap_file_name}\" into a persistent swap file.\n";
    exit 0;
  fi
