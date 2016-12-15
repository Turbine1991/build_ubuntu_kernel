#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Includes
. functions.sh

##Download Dependencies
apt-get update

#Detect and enable source repository when required
apt-get build-dep linux-image-`uname -r`
#STR_APT_DEP="apt-get build-dep linux-image-`uname -r`"
#if [[ -z $($STR_APT_DEP 2>&1 | awk '{print $4}' | grep "source") ]]; then
#  apt-get install software-properties-common
#  cat /etc/apt/sources.list | grep -e "^deb http://" | head -1 | awk '{ printf "deb-src %s %s main", $2, $3 }' >> /etc/apt/sources.list
#  apt-get update
#  $STR_APT_DEP
#fi
#

apt-get install curl kernel-package libncurses5-dev fakeroot wget bzip2 libssl-dev liblz4-tool git
#

{
if [[ -f "kernel/mainline-crack/.config" ]]; then
  cp "kernel/mainline-crack/.config" ./
fi

rm -R kernel
mkdir kernel
cd kernel

##Setup
KERNEL_SOURCE_URL="http://kernel.ubuntu.com/~kernel-ppa/mainline"

##Manage kernel version
#Declare
versions="daily 4.9 4.8 4.7 4.6 4.1 "

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
  "4.5")
    WASTEDCORES_BRANCH="linux-4.5"
  ;;

  "4.4")
    WASTEDCORES_BRANCH="linux-4.4"
  ;;

  "4.1")
    WASTEDCORES_GIT="https://github.com/jplozi/wastedcores.git"
    WASTEDCORES_BRANCH="master"
  ;;

  *)
    WASTEDCORES_BRANCH="master"
  ;;
esac

if [[ $version == "daily" ]]; then
  KERNEL_VERSION="$version"

  KERNEL_SOURCE_URL="$KERNEL_SOURCE_URL/daily/current"

  PATCH_URL="$KERNEL_SOURCE_URL"
else
  KERNEL_VERSION="$version"

  ##Find latest kernel version in a specific branch
  PATCH_DIR=`get_http_apache_listing "$KERNEL_SOURCE_URL" "v$KERNEL_VERSION" 1`
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

#Prompt for scheduler
URL_MUQSS="http://ck.kolivas.org/patches/muqss/4.0"

VERSIONS_WASTEDCORES="4.6 4.5 4.4 4.1"
VERSIONS_MUQSS=`get_http_apache_listing "$URL_MUQSS" | tr '\n' ' '`

VERSIONS_SCHEDULERS="cfs "
VERSIONS_SCHEDULERS="$VERSIONS_SCHEDULERS "`match_str "$VERSIONS_WASTEDCORES" "$KERNEL_VERSION" "wastedcores"`
VERSIONS_SCHEDULERS="$VERSIONS_SCHEDULERS "`match_str "$VERSIONS_MUQSS" "$KERNEL_VERSION" "muqss"`

#Scheduler Prompt
versions=$VERSIONS_SCHEDULERS
versions_max=$(sa_get_count "$versions")

#List kernel version choices
printf "\nSchedulers Available - $KERNEL_VERSION\n"

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

case $version in
  "wastedcores")
    git clone --depth=1 --branch="$WASTEDCORES_BRANCH" "$WASTEDCORES_GIT"

    cp wastedcores/patches/*.patch ./
    rm -R wastedcores
  ;;

  "muqss")
    url="$URL_MUQSS/$KERNEL_VERSION/"`get_http_apache_listing "$URL_MUQSS/$KERNEL_VERSION" "${KERNEL_VERSION}-sched-MuQSS" 1`
    wget "$url"
  ;;
esac

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

#Generate config prompt
read -p "Generate a localmodconfig (y/n): " -n 1
if [[ $REPLY =~ ^[Yy]$ ]]; then
  make localmodconfig
else
  make oldconfig
fi
}
