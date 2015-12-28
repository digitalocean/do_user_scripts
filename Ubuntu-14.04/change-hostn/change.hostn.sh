#!/bin/sh
#Change droplet's current hostname to user defined hostname
#Ubuntu 14.04 

#Assign user input to $newhostn 
newhostn="<%newhostn%>"

#Assign current hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
echo "Existing hostname is $hostn"

#Display change to be made
echo "New hostname will be $newhostn" 

#Change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhostn/g" /etc/hosts
sed -i "s/$hostn/$newhostn/g" /etc/hostname

#Make changes to droplet permanent 
reboot
