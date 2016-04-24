# Compile your own Ubuntu WastedCores kernel!

## What this does:
* Downloads all the dependencies necessary to build a kernel.
* Clones the latest Ubuntu Linux kernel of branch v4.5, applies all of the standard patches.
* Clones and applies wastedcores patches.
* Sneakily applies the CPU target patch, enabling you to target a greater range of cpu architectures - primarily the native arch.
* Prompts whether you'd like to generate a localmodconfig.
* Displays a menu for you to modify the kernel.
* Lets you build the kernel into a .deb package.
*  whether you'd like to install the kernel.

## Requirements:
* Ubuntu Linux. Wily or Xenial recommended.
* Use a stock kernel when using these scripts, for dependency resolution.
* No real kernel experience or in-depth knowledge of Linux.

## How to use, run these commands in-order:
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
