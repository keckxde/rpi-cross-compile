#!/usr/bin/env bash
# Store your password in a file called .sshpasswd
# Store your SSH-Target machine in a file called SSHTARGET (contents e.g. user@host)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
INSTALL_OPTIONAL="no"
ROOTFS_DIR=./rootfs
HOSTINFO_FILE=${ROOTFS_DIR}/host-info.md
USER=saph
SSHTARGET=$(cat SSHTARGET) 
mkdir -p ${ROOTFS_DIR}/usr ${ROOTFS_DIR}/opt ${ROOTFS_DIR}/etc ${ROOTFS_DIR}/var/lib/dpkg

echo -e "\n\nSYNC MANDATORY FOLDERS ...\n\n"

sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/lib ${ROOTFS_DIR}/usr
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/lib ${ROOTFS_DIR}
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/include ${ROOTFS_DIR}/usr
sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/opt/vc ${ROOTFS_DIR}/opt

if [ "$INSTALL_OPTIONAL" = "no" ]; then
    echo -e "\n\nDO NOT SYNC OPTIONAL FOLDERS (bin/etc/...\n\n"
else
    echo -e "\n\nSYNC OPTIONAL FOLDERS (bin/etc/..."
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/bin ${ROOTFS_DIR}/usr
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/bin ${ROOTFS_DIR}
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/usr/sbin ${ROOTFS_DIR}/usr
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/sbin ${ROOTFS_DIR}
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/var/lib/dpkg ${ROOTFS_DIR}/var/lib/
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/etc/alternatives ${ROOTFS_DIR}/etc
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/etc/passwd ${ROOTFS_DIR}/etc
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/etc/group ${ROOTFS_DIR}/etc
    sshpass -p $(cat .sshpasswd) rsync -avz --rsync-path="sudo rsync" --delete ${SSHTARGET}:/etc/ssl ${ROOTFS_DIR}/etc
fi

echo -e "\n\nFIXING RELATIVE LINKS INSIDE ROOTFS...\n\n"

# Correct relative links
${SCRIPT_DIR}/sysroot-relativelinks.py ${ROOTFS_DIR}

echo -e "\n\nSAVE TARGET INFO INTO FILE...\n\n"

# Save the reference for installed packages on the target system
sshpass -p $(cat .sshpasswd) ssh ${SSHTARGET} "dpkg -l" > ${ROOTFS_DIR}/dpkg-list.txt
# Save Host-Info
echo -e "# HOST-INFO:" > ${HOSTINFO_FILE}
echo -e "\n## Short:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${SSHTARGET} "uname -a" >> ${HOSTINFO_FILE}
echo -e "\n## SW-Packages\nSee [dpkg-list.txt](dpkg-list.txt)" >> ${HOSTINFO_FILE}

echo -e "\n# SYSTEM - INFO:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${SSHTARGET} "lsb_release -a" >> ${HOSTINFO_FILE}
echo -e "\n# CPU - INFO:" >> ${HOSTINFO_FILE}
sshpass -p $(cat .sshpasswd) ssh ${SSHTARGET} "lscpu" >> ${HOSTINFO_FILE}

