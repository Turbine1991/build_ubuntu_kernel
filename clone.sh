#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Includes
. functions.sh

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
KERNEL_SOURCE_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline"

##Manage kernel version
#Declare
versions="daily 4.6 4.1 "

#Retrieve patch branches from git
branches=$(get_git_branches "https://github.com/Freeaqingme/wastedcores.git")
versions="$versions$branches"

#Initialise
versions_max=$(sa_get_count "$versions")

#Order
versions=$(sa_sort "$versions")
versions=$(sa_reverse "$versions")

#List kernel version choices
printf "\nKernel Versions\n"

print_choices "$versions"

#Prompt
printf "Please enter your choice: "
while read i
do
  #Check if valid input, is a number, is within choice boundaries
  if [[ -z "$i" || "$i" -ne "$i" || "$i" > "$versions_max" ]]
  then
    printf "Try again: "
  else
    break
  fi
done

version=$(sa_get_value "$versions" $((i-1)))

#Process selected kernel version
WASTEDCORES_GIT="https://github.com/Freeaqingme/wastedcores.git"
case $version in
  "daily")
    WASTEDCORES_BRANCH="HEAD"
  ;;
  
  "4.6")
    WASTEDCORES_BRANCH="linux-4.5"
  ;;

  "4.1")
    WASTEDCORES_GIT="https://github.com/jplozi/wastedcores.git"
    WASTEDCORES_BRANCH="HEAD"
  ;;

  *)
    WASTEDCORES_GIT="https://github.com/Freeaqingme/wastedcores.git"
    WASTEDCORES_BRANCH="linux-$version"
  ;;
esac

if [[ $version == "daily" ]]; then
  KERNEL_VERSION="$version"

  KERNEL_SOURCE_URL="$KERNEL_SOURCE_URL/daily/current"

  PATCH_URL="$KERNEL_SOURCE_URL"
else
  KERNEL_VERSION="v$version"

  ##Find latest kernel version in a specific branch
  KERNEL_SOURCE_URL_REQUEST="$KERNEL_SOURCE_URL/?C=M;O=D"
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
fi

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
git clone "$WASTEDCORES_GIT"

cp wastedcores/patches/*.patch ./
rm -R wastedcores

#Download additional CPU optimizations patch
wget https://raw.githubusercontent.com/graysky2/kernel_gcc_patch/master/enable_additional_cpu_optimizations_for_gcc_v4.9%2B_kernel_v3.15%2B.patch
#

cd ..

#Download kernel source
KERNEL_LINE=$(head -1 SOURCES)
KERNEL_BRANCH=$(echo "$KERNEL_LINE" | awk '{ print $2 }')
STR_GIT_LINUX=$(echo "$KERNEL_LINE" | awk '{ printf "git clone --depth=1 --branch=%s %s", $2, $1 }')
$STR_GIT_LINUX

#Patch source
cd "mainline-crack"

for f in ../patch/*
do
  patch -p1 -i "$f"
done

#Dirty compilation error fix - has been resolved thanks to Freeaqingme's modified scheduler patches
if [[ $version == "4.1" ]]; then
  sed -i '80iextern int sched_max_numa_distance;' arch/x86/kernel/smpboot.c
fi

#Generate config prompt
read -p "Generate a localmodconfig (y/n): " -n 1
if [[ $REPLY =~ ^[Yy]$ ]]; then
  make localmodconfig
else
  make oldconfig
fi
}
