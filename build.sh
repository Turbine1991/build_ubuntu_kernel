#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Includes
. functions.sh

##Setup
BUILD_PREFIX=$(cat_contents "BUILD_PREFIX")

##Retrieve/increment build value
BUILD_COUNT=$(cat ".build_count")
((BUILD_COUNT++))
echo "$BUILD_COUNT" > .build_count
#

##Declare
DEB_FILE=$BUILD_PREFIX$BUILD_COUNT

cd "kernel"

(
##Build into .deb package
cd "mainline-crack"

##Experiment with some optimizations
export CFLAGS=' -march=native -mtune=native -Ofast -fmodulo-sched -fmodulo-sched-allow-regmoves ' \
		&& export CXXFLAGS=' -march=native -mtune=native -mcpu=native -Ofast -fwhole-program' \
		&& export LDFLAGS=' -fwhole-program '
		
# (broken) -fwhole-program

make clean && fakeroot make-kpkg -j`nproc` --initrd --append-to-version=$DEB_FILE kernel_image kernel_headers

echo "Everything's Complete"
)

##Request and attempt installation of compiled packages
if ls *$DEB_FILE*.deb 1> /dev/null 2>&1; then
  read -p "Install kernel (y/n): " -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    dpkg -i *$DEB_FILE*.deb
    
    echo "Please Reboot"
  fi
fi
