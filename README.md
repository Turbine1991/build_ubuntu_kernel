# Compile your own Ubuntu WastedCores kernel!

## What this does:
* Downloads all the dependencies necessary to build a kernel.
* Lets you choose a Linux kernel version.
* Applies WastedCores patches compatible with the kernel version.
* Displays a menu for you to modify the kernel.
* Lets you build the kernel into a .deb package.

## Requirements:
* Ubuntu Linux. Wily or Xenial recommended.
* Use a stock kernel when using these scripts, for dependency resolution.
* No real kernel experience or in-depth knowledge of Linux.

## How to use, simply run:
* sudo apt-get update && sudo apt-get install git
* git clone https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores.git
* cd build_ubuntu_kernel_wastedcores
* sudo bash clone.sh
* sudo bash menu.sh
* sudo bash build.sh

## Article
http://www.ece.ubc.ca/~sasha/papers/eurosys16-final29.pdf

**The Linux Scheduler: a Decade of Wasted Cores**, Jean-Pierre Lozi, Baptiste
Lepers, Justin Funston, Fabien Gaud, Vivien Quéma, and Alexandra Fedorova. *To
appear in* Proceedings of the Eleventh European Conference on Computer Systems
*(EuroSys '16), London, United Kingdom, 2016.*

## Scheduler Kernel Patches
**Improved Compatibility:** https://github.com/Freeaqingme/wastedcores

**Source:** https://github.com/jplozi/wastedcores
