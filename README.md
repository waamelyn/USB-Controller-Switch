# USB Controller Switch Script

The function of this script is to unbind the USB controllers from your Host PC and bind them to vfio-pci, which will enable them to be used in qemu and virt-manager.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Acknowledgements](#acknowledgements)

## Overview
This script uses echo commands to bind your USB controller to either your Host PC or vfio-pci, which allows your USB controller to be forwarded to your Virtual Machines in virt-manager. It starts and ends with status checks to see where they are currently bound.

This script will enable you to forward a whole USB controller rather than just one device. One example use case--my reason for creating this script--is trying to connect an Android Device in bootrom mode to an application in a Windows VM from an Arch Linux machine: in bootrom mode, the device connects and disconnects very quickly, so there is not time to select it in virt-manager; this solves the issue by forwarding the whole USB controller.

## Prerequisites
- Linux Computer with Grub bootloader
- QEMU/KVM and virt-manager
- IOMMU-capable hardware
- Root/sudo access (script uses `sudo tee` commands)

## Installation

### 1. Find your machine's USB Controller IDs

The USB controllers in this script are specific to my machine. Find your controllers with:

`lspci -nn | grep USB`

Example output:
00:14.0 USB controller [0c03]: Intel Corporation Alder Lake PCH USB 3.2 xHCI Host Controller [8086:51ed] (rev 01)

From this example:
- Controller ID: 00:14.0 → Replace 0000:XX:XX.X with 0000:00:14.0 in the script
- Device ID: 8086 51ed → Replace XXXX XXXX with 8086 51ed in the script
- For GRUB config: Use 8086:51ed

### 2. Edit the Grub Config

In /etc/default/grub, find the line with "GRUB_CMDLINE_LINUX_DEFAULT", and in the parentheses, add the following:

`intel_iommu=on iommu=pt vfio-pci.ids=8086:51ed,8086:1137,8086:1138`

Note: use `amd_iommu=on` for AMD systems.

Replace "XXXX:XXXX" with your specific controller IDs.

### 3. Update grub

After editing /etc/default/grub, run the following:

`sudo grub-mkconfig -o /boot/grub/grub.cfg`

### 4. Edit Initramfs Configuration

Edit /etc/mkinitcpio.conf and find `MODULES=()`. Add these modules:

`MODULES=(vfio_pci vfio vfio_iommu_type1)`

### 5. Rebuild Initramfs and Reboot

After editing /etc/mkinitcpio.conf, run the following:

`sudo mkinitcpio -p linux`
`sudo reboot`

## Usage

To make executable:
`chmod +x /path/to/usb_controller_switch`

Then, to run the script:
`./path/to/usb_controller_switch`

Alternatively, you can move the script to `~/.local/bin/` . 
(Make sure `~/.local/bin` is in your path in `~/.bashrc` !)
Then, from anywhere:
`usb_controller_switch`



## Acknowledgements

Written by waamelyn.
Feel free to modify and use this script!
