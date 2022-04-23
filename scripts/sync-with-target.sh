#!/usr/bin/env bash
# Store your password in a file called .sshpasswd
# Store your SSH-Target machine in a file called SSHTARGET (contents e.g. user@host)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOTFS_DIR=./rootfs
HOSTINFO_FILE=${ROOTFS_DIR}/host-info.md
USER=saph
SSHTARGET=$(cat SSHTARGET) 
mkdir -p ${ROOTFS_DIR}/usr ${ROOTFS_DIR}/opt

sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/lib ${ROOTFS_DIR}/usr
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/lib ${ROOTFS_DIR}
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/include ${ROOTFS_DIR}/usr
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/opt/vc ${ROOTFS_DIR}/opt

# Save the reference for installed packages on the target system
sshpass -p $(cat .sshpasswd) ssh ${SSHTARGET} "dpkg -l" > ${ROOTFS_DIR}/dpkg-list.txt
# Save Host-Info
echo -e "# HOST-INFO:" > ${HOSTINFO_FILE}
echo -e "\n## Short:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${USER}@${TARGET} "uname -a" >> ${HOSTINFO_FILE}
echo -e "\n## SW-Packages\nSee [dpkg-list.txt](dpkg-list.txt)" >> ${HOSTINFO_FILE}

echo -e "\n# SYSTEM - INFO:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${USER}@${TARGET} "lsb_release -a" >> ${HOSTINFO_FILE}
echo -e "\n# CPU - INFO:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${USER}@${TARGET} "lscpu" >> ${HOSTINFO_FILE}


# Correct relative links
${SCRIPT_DIR}/sysroot-relativelinks.py ${ROOTFS_DIR}