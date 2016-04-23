#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Download Dependencies
apt-get update

#Detect and enable source repository when required
STR_APT_DEP="apt-get build-dep linux-image-`uname -r`"
if [[ -z $($STR_APT_DEP 2>&1 | awk '{print $4}' | grep "source") ]]; then
  apt-get install software-properties-common
  cat /etc/apt/sources.list | grep -e "^deb http://" | head -1 | awk '{ printf "deb-src %s %s main", $2, $3 }' >> /etc/apt/sources.list
  apt-get update
  $STR_APT_DEP
fi
#

apt-get install curl kernel-package libncurses5-dev fakeroot wget bzip2 libssl-dev liblz4-tool git
#

{
rm -R kernel
mkdir kernel
cd kernel

##Setup
PATCH_SOURCE_GIT="https://github.com/Freeaqingme/wastedcores.git"
#PATCH_SOURCE_GIT="https://github.com/jplozi/wastedcores.git"
KERNEL_SOURCE_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline"
KERNEL_SOURCE_URL_REQUEST="$KERNEL_SOURCE_URL/?C=M;O=D"
KERNEL_VERSION="v4.1"

##Find latest kernel version in a specific branch
PATCH_DIR=$(curl "$KERNEL_SOURCE_URL_REQUEST" 2> /dev/null \
		| grep "<a href=" \
		| sed "s/<a href/\\n<a href/g" \
		| sed 's/\"/\"><\/a>\n/2' \
		| grep href \
		| awk '{ print $2 }' \
		| cut -d '"' -f2 \
		| grep "$KERNEL_VERSION" \
		| head -1)

PATCH_URL="$KERNEL_SOURCE_URL/$PATCH_DIR"

##Get kernel data
wget "$PATCH_URL/SOURCES"

##Retrieve patches

mkdir patch
cd patch

#Download kernel patches
while read f; do
  if [[ $f == *".patch" ]]; then
    wget "$PATCH_URL/$f"
  fi
done < "../SOURCES"

#Download scheduler patches
git clone "$PATCH_SOURCE_GIT"

cp wastedcores/patches/*.patch ./
rm -R wastedcores

#Download additional CPU optimizations patch
wget https://raw.githubusercontent.com/graysky2/kernel_gcc_patch/master/enable_additional_cpu_optimizations_for_gcc_v4.9%2B_kernel_v3.15%2B.patch
#

cd ..

#Download kernel source
STR_GIT_LINUX=$(head -1 SOURCES | awk '{ printf "git clone --depth=1 --branch=%s %s", $2, $1 }')

$STR_GIT_LINUX

#Patch source
cd "mainline-crack"

for f in ../patch/*
do
  patch -p1 -i "$f"
done

#Dirty fix for compiler error described at: https://gist.github.com/brendangregg/588b1d29bcb952141d50ccc0e005fcf8
#Please can somebody advise on a better automated solution
#This line inserts the extern line into line 80 of a source file
sed -i '80iextern int sched_max_numa_distance;' arch/x86/kernel/smpboot.c

#Generate config prompt
read -p "Generate a localmodconfig (y/n): " -n 1
[[ $REPLY =~ ^[Yy]$ && type=localmodconfig || type=oldconfig ]] && make $type
}
