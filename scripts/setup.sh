#!/usr/bin/env bash

# Install some useful packages using apt:
sudo apt install -y sshpass python3

# Install the cross-compile toolchain:
TOOLS_DIR=tools
VERSION=cross-gcc-10.3.0-pi_64
mkdir -p ${TOOLS_DIR}
pushd ${TOOLS_DIR}
rm -r *
wget https://netix.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Bonus%20Raspberry%20Pi%20GCC%2064-Bit%20Toolchains/Raspberry%20Pi%20GCC%2064-Bit%20Cross-Compiler%20Toolchains/Bullseye/GCC%2010.3.0/${VERSION}.tar.gz
tar xf ${VERSION}.tar.gz
TOOL_CHAIN=`ls -d */`
echo "TOOL:" ${TOOL_CHAIN}
popd

# create some initial-files
DEFAULT_TARGET="user@192.168.25.222"
DEFAULT_PASSWD="password"
[ ! -f "SSHTARGET" ] &&  echo ${DEFAULT_TARGET} > SSHTARGET
[ ! -f ".sshpasswd" ] &&  echo ${DEFAULT_PASSWD} > .sshpasswd
TOOLCHAIN_RELDIR=${TOOLS_DIR}/${TOOL_CHAIN}
TOOLCHAIN_ABSDIR=`echo -n $(cd "$(dirname "$TOOLCHAIN_RELDIR")"; pwd)/$(basename "$TOOLCHAIN_RELDIR")`
ROOTFS_ABSDIR=`echo -n $(cd "$(dirname "rootfs")"; pwd)/$(basename "rootfs")`
echo "REL" ${TOOLCHAIN_RELDIR}
echo "ABS" ${TOOLCHAIN_ABSDIR}
echo -n ${TOOLCHAIN_ABSDIR} > TOOLCHAIN


sudo tee -a > PI.cmake  <<EOT
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(tools ${TOOLCHAIN_ABSDIR}) # warning change toolchain path here.
set(rootfs_dir ${ROOTFS_ABSDIR})

set(CMAKE_FIND_ROOT_PATH \${rootfs_dir})
set(CMAKE_SYSROOT \${rootfs_dir})

set(CMAKE_LIBRARY_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_EXE_LINKER_FLAGS "\${CMAKE_EXE_LINKER_FLAGS} -fPIC -Wl,-rpath-link,\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE} -L\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE}")
set(CMAKE_C_FLAGS "\${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE} -L\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE}")
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE} -L\${CMAKE_SYSROOT}/usr/lib/\${CMAKE_LIBRARY_ARCHITECTURE}")
## Compiler Binary 
SET(BIN_PREFIX \${tools}/bin/aarch64-linux-gnu)

SET (CMAKE_C_COMPILER \${BIN_PREFIX}-gcc)
SET (CMAKE_CXX_COMPILER \${BIN_PREFIX}-g++ )
SET (CMAKE_LINKER \${BIN_PREFIX}-ld 
            CACHE STRING "Set the cross-compiler tool LD" FORCE)
SET (CMAKE_AR \${BIN_PREFIX}-ar 
            CACHE STRING "Set the cross-compiler tool AR" FORCE)
SET (CMAKE_NM {BIN_PREFIX}-nm 
            CACHE STRING "Set the cross-compiler tool NM" FORCE)
SET (CMAKE_OBJCOPY \${BIN_PREFIX}-objcopy 
            CACHE STRING "Set the cross-compiler tool OBJCOPY" FORCE)
SET (CMAKE_OBJDUMP \${BIN_PREFIX}-objdump 
            CACHE STRING "Set the cross-compiler tool OBJDUMP" FORCE)
SET (CMAKE_RANLIB \${BIN_PREFIX}-ranlib 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)
SET (CMAKE_STRIP {BIN_PREFIX}-strip 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE arm64)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT) 
EOT

