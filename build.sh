#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Experiment with some compiler flags
#export CFLAGS=' -march=native -mtune=native -mcpu=native -Ofast -fwhole-program -fmodulo-sched -fmodulo-sched-allow-regmoves ' \
#		&& export CXXFLAGS=' -march=native -mtune=native -mcpu=native -Ofast -fwhole-program' \
#		&& export LDFLAGS=' -fwhole-program '

##Retrieve/increment build value
BUILD_COUNT=$(cat ".build_count")
((BUILD_COUNT++))
echo "$BUILD_COUNT" > .build_count
#

cd "kernel"

(
##Build into .deb package
cd "mainline-crack"
make clean && fakeroot make-kpkg -j`nproc` --initrd --append-to-version=custom$BUILD_COUNT kernel_image kernel_headers
)

##Install
DEB_WILDCARD="*custom$BUILD_COUNT*.deb"

if [[ -f $DEB_WILDCARD ]]; then
  read -p "Install kernel (y/n): " -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    dpkg -i $DEB_WILDCARD
  fi
fi
