#!/usr/bin/env bash 
###################
#
# Swap File Creator
#
# Purpose: This script will create a swap file on your droplet,
#   and configure it to be persistent across reboots.
#
# Usage: Copy and paste contents of file into "User Data" at time of droplet creation.
#   Update <%REQUESTED_SWAP_SIZE%> and <%SWAP_FILE_NAME%> before creating droplet.
#
# Note: the size must be in whole gigabytes; only use positive, whole numbers.
    req_swap_size=<%REQUESTED_SWAP_SIZE%>;
#
# Note: the swap file will be located in the "/" directory; provide only a name, no slashes or tildes.
    req_swap_file_name=<%SWAP_FILE_NAME%>;
#
###################

# Start system log entries
  logger "[CLOUDINIT] INFO: Swap File Creator script invoked."

# Runs checks on user inputs to ensure swap file name is valid.
  swap_file_name=${req_swap_file_name//[/~]};
  if [[ "${#req_swap_file_name}" != "${#swap_file_name}" ]]; then
    logger "[CLOUDINIT] ERROR: Invalid swap file name of \"${req_swap_size}\" no slashes or tildes allowed."
    exit 1;
  fi

# Runs checks on user inputs to ensure swap file name is not in use already.
  if [[ -e "/${swap_file_name}" ]]; then
    logger "[CLOUDINIT] INFO: Swap file path/name already in use.";
    exit 1;
  fi
  
# Runs checks on user inputs to ensure swap file size is valid and disk space is available.
  swap_size=${req_swap_size//[^0-9]};
  if [[ "${#req_swap_size}" != "${#swap_size}" ]]; then
    logger "[CLOUDINIT] ERROR: Invalid swap size of \"${req_swap_size}\" gigabytes requested; use positive whole numbers only."
    exit 1;
  fi
  type df > /dev/null && \
  avail_disk=$(df -B G --output=avail /);
  avail_disk=${avail_disk//[^0-9]};
  if [[ "${avail_disk}" -lt "${swap_size}" ]]; then
    logger "[CLOUDINIT] ERROR: Not enough disk space to create swap file of requested size: ${swap_size}G.";
    exit 1;
  fi
  logger "[CLOUDINIT] INFO: Requested swap size of \"${swap_size}G\" is valid and disk space is available.";

# Uses the 'fallocate' binary to create a swap file.
  type fallocate &>/dev/null && \
  fallocate -l ${swap_size}G ${swap_file_name} &>/dev/null;
  if [[ ! -e "${swap_file_name}" ]]; then
    logger "[CLOUDINIT] ERROR: Unable to create ${swap_size}G-sized swap file at location: \"${swap_file_name}\"";
    exit 1;
  fi
  logger "[CLOUDINIT] INFO: Successfully created ${swap_size}G-sized file at location: \"${swap_file_name}\"";

# Makes the newly created regular file into a swap file.
  logger "[CLOUDINIT] INFO: Now attempting to change newly created file into a persistent swap file...";
  chmod 600 ${swap_file_name} &>/dev/null && \
  mkswap ${swap_file_name} &>/dev/null && \
  swapon ${swap_file_name} &>/dev/null && \
  echo "${swap_file_name}   none    swap    sw    0   0" >> /etc/fstab;
 
  show_swaps() {
    logger "[CLOUDINIT] INFO: All currently active swap files and partitions:";
	  while read line; do
      printf "[CLOUDINIT] INFO: \t$line\n" >> /var/log/messages;
    done <<<"$(cat /proc/swaps)"
    logger "[CLOUDINIT] INFO: Execution complete; Swap File Creator script exiting.";
  }
  
# Tell user the results of the script.
  if [[ "${?}" != "0" ]]; then
    logger "[CLOUDINIT] ERROR: Failed to change file \"${swap_file_name}\" into a persistent swap file.";
    show_swaps;
    exit 1;
  else
    logger -s "[CLOUDINIT] INFO: Successfully changed regular file \"${swap_file_name}\" into a persistent swap file.";
    show_swaps;
    exit 0;
  fi
