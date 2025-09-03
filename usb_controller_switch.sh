#!/bin/bash

#
# usb_controller_switch.sh
# 
# Purpose: when run, this will switch usb controller access from the host machine to vfio-pci, allowing the usb controller to be used from a virtual machine in virt-manager.
#
# This is specific to my machine! Read the README.md for more info.
#



#------------------------------------------------------

# Status check

read -p "Print current status? (y/n): " current_status1

if [ "$current_status1" = "y" ]; then
	# Check current drivers
	lspci -k -s 00:14.0
	lspci -k -s 22:00.0
	lspci -k -s 56:00.0
	# Check if bound to vfio-pci
	ls /sys/bus/pci/drivers/vfio-pci/ 2>/dev/null | grep 0000 || echo "No devices bound to vfio-pci."
elif [ "$current_status1" = "n" ]; then
	echo "Skipping status check."
else
	echo 'Unexpected value: expected "y" or "n".'
fi

#------------------------------------------------------

echo # blank line

#------------------------------------------------------

read -p "Bind/Unbind USB controllers? (u=unbind from host, b=bind back to host, e=exit): " answer

#------------------------------------------------------

# Binding/Unbinding USB controllers
if [ "$answer" = "u" ]; then
	echo "Unbinding USB controllers from Host..."
	echo # blank line
	# Unbind from current drivers
	echo "0000:00:14.0" | sudo tee /sys/bus/pci/devices/0000:00:14.0/driver/unbind 2>/dev/null || echo "00:14.0 already unbound or error."
	echo "0000:22:00.0" | sudo tee /sys/bus/pci/devices/0000:22:00.0/driver/unbind 2>/dev/null || echo "22:00.0 already unbound or error."
	echo "0000:56:00.0" | sudo tee /sys/bus/pci/devices/0000:56:00.0/driver/unbind 2>/dev/null || echo "56:00.0 already unbound or error."
	# Bind to vfio-pci (for virtual machine use)
	echo "0000:00:14.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind || echo "Warning: Failed to bind 00:14.0 to vfio-pci."
	echo "0000:22:00.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind || echo "Warning: Failed to bind 22:00.0 to vfio-pci."
	echo "0000:56:00.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind || echo "Warning: Failed to bind 56:00.0 to vfio-pci."
	# Message
	echo "The drivers have been bound to vfio-pci."
elif [ "$answer" = "b" ]; then
	echo "Unbinding USB controllers from vfio-pci..."
	echo # blank line
	# Unbind from vfio-pci
	echo "0000:00:14.0" | sudo tee /sys/bus/pci/devices/0000:00:14.0/driver/unbind 2>/dev/null || echo "00:14.0 already unbound or error."
	echo "0000:22:00.0" | sudo tee /sys/bus/pci/devices/0000:22:00.0/driver/unbind 2>/dev/null || echo "22:00.0 already unbound or error."
	echo "0000:56:00.0" | sudo tee /sys/bus/pci/devices/0000:56:00.0/driver/unbind 2>/dev/null || echo "56:00.0 already unbound or error."
	# Bind back to Host
	echo "8086 51ed" | sudo tee /sys/bus/pci/drivers/xhci_hcd/new_id || echo "Warning: Failed to bind 8086 51ed to Host."
	echo "8086 1137" | sudo tee /sys/bus/pci/drivers/thunderbolt/new_id || echo "Warning: Failed to bind 8086 1137 to Host."
	echo "8086 1138" | sudo tee /sys/bus/pci/drivers/xhci_hcd/new_id || echo "Warning: Failed to bind 8086 1138 to Host."
	# Message
	echo "The drivers have been bound to the Host."
elif [ "$answer" = "e" ]; then
	echo "Exiting process."
	exit 0
else
	echo "Unexpected value: Expected 'y', 'n', or 'e'."
	echo "Exiting process."
	exit 0
fi

#------------------------------------------------------

echo # blank line

#------------------------------------------------------

# status check
read -p "Print current status? (y/n): " current_status2

if [ "$current_status2" = "y" ]; then
	# Check current drivers
	lspci -k -s 00:14.0
	lspci -k -s 22:00.0
	lspci -k -s 56:00.0
	# Check if bound to vfio-pci
	ls /sys/bus/pci/drivers/vfio-pci/ 2>/dev/null | grep 0000 || echo "No devices bound to vfio-pci."
elif [ "$current_status2" = "n" ]; then
	echo "Skipping status check."
else
	echo 'Unexpected value: expected "y" or "n"'
fi
