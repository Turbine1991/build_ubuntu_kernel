#!/bin/bash

#GitHub This: https://github.com/Turbine1991/build_ubuntu_kernel_wastedcores
#GitHub WastedCores: https://github.com/jplozi/wastedcores

##Retrieve/increment build value
BUILD_COUNT=$(cat ".build_count")
((BUILD_COUNT++))
echo "$BUILD_COUNT" > .build_count
#

cd "kernel"

(
##Build into .deb package
cd "mainline-crack"

##Experiment with some optimizations
#export CFLAGS=' -march=native -mtune=native -mcpu=native -Ofast -fwhole-program -fmodulo-sched -fmodulo-sched-allow-regmoves ' \
#		&& export CXXFLAGS=' -march=native -mtune=native -mcpu=native -Ofast -fwhole-program' \
#		&& export LDFLAGS=' -fwhole-program '
#
#if [[ ! -f .optimized ]] then
  #Put optimizations into Makefile
#  sed -i '/HOSTCFLAGS   =/c\HOSTCFLAGS   = -march=native -mtune=native -Ofast -fmodulo-sched -fmodulo-sched-allow-regmoves -fno-tree-vectorize -std=gnu89' Makefile
#  sed -i '/HOSTCXXFLAGS =/c\HOSTCXXFLAGS = -march=native -mtune=native -Ofast' Makefile
#  touch .optimized
#fi

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
