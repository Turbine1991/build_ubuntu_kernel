# Start compiling your very own Ubuntu Linux kernel with wastedcores in under a minute (optimistically)

What this does:
* Downloads all the dependencies necessary to build a kernel.
* Clones the latest Ubuntu Linux kernel of branch v4.5, applies all of the standard patches.
* Clones and applies wastedcores patches.
* Sneakily applies the CPU target patch, enabling you to target a greater range of cpu architectures - primarily the native arch.
* Prompts whether you'd like to generate a localmodconfig.
* Displays a menu for you to modify the kernel.
* Lets you build the kernel into a .deb package.
*  whether you'd like to install the kernel.

Requirements:
* Ubuntu Linux Wily or Xenial recommended.
* Use a stock kernel when using these scripts, for dependency resolution.

How to use, run these commands in-order:
* sudo apt-get update && sudo apt-get install git
* git clone https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores.git
* cd build_ubuntu_kernel_wastedcores
* sudo bash clone.sh
* sudo bash menu.sh
* sudo bash build.sh
