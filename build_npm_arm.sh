#!/bin/bash
#
# Script to cross-compile NPM modules for arm.  Based on
# linino work and modified to fit into the AOSP tree.
#
# Requires you to install node and NPM on your host system first
# - I think any version works since we compile against the 
# specific node/v8 headers from the tree.
#
# Jared G
#

# -- Main settings --

export BASEDIR=~/aosp

# Prefix for compilation tools
export PREFIX=${BASEDIR}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/arm-linux-androideabi- 

# Main prebuilt to base on
export PREBUILT=${BASEDIR}/prebuilts/ndk/9
export SYSROOT=${PREBUILT}/platforms/android-18/arch-arm

# Prebuilt include and library paths
export INCPATH=${SYSROOT}/usr/include
export LIBPATH=${SYSROOT}/usr/lib

# STL include and library paths for using stlport
export INCPATH_STLPORT=${PREBUILT}/sources/cxx-stl/stlport/stlport
export LIBPATH_STLPORT=${PREBUILT}/sources/cxx-stl/stlport/libs/armeabi-v7a

# Path to node for compilation
export NODESRCDIR=${BASEDIR}/external/node-aosp


# -- Cross-compile exports --

export CC=${PREFIX}gcc
export CXX=${PREFIX}g++
export AR=${PREFIX}ar
export RANLIB=${PREFIX}ranlib
export LINK=${PREFIX}g++
export CPP="${PREFIX}gcc -E"
export STRIP=${PREFIX}strip
export OBJCOPY=${PREFIX}objcopy
export LD=${PREFIX}ld
export OBJDUMP=${PREFIX}objdump
export NM=${PREFIX}nm
export AS=${PREFIX}as
export PS1="[${PREFIX}] \w$ "


# -- Set up linker to use correct libraries/headers --

# Add the search path for libstlport
export LDFLAGS="--sysroot ${SYSROOT} -L${LIBPATH_STLPORT}"

# Important so that gyp can find the system includes in AOSP, including STL and STL bits
export CFLAGS="--sysroot ${SYSROOT}"
export CXXFLAGS="--sysroot ${SYSROOT} -I${INCPATH_STLPORT}"
 

# -- Set up NPM variables --

# Set up target platform and path to node for includes and stuff
export npm_config_arch=arm
export npm_config_platform=android
export npm_config_nodedir=${NODESRCDIR}

# Important, force GYP to use OS=android so we can differentiate
export GYP_DEFINES="OS=android"

# Build to this path for now
export BUILD_DIR=${npm_config_arch}_modules_$2

# Make the build directory and enter it
if [ ! -d $(pwd)/${BUILD_DIR} ]; then
        mkdir $(pwd)/${BUILD_DIR}
fi
cd ${BUILD_DIR}

# Get the version for stamping if needed, off for now
#version=`npm view "$1" version`


# -- Run the actual build --

# Start the build
npm install --target_platform=android --target_arch=${npm_config_arch} "$1"

if [ $? -eq 1 ]
then
    echo " "
    echo "Cross build of package failed!"
    echo " "
    exit 0
else
    echo ""
    echo "Cross build successful for $1!"
    echo ""
fi
