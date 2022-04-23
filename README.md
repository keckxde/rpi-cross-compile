# Cross-Compilation toolchain for RPI

based on explanations from [abhiTronix](https://github.com/abhiTronix/raspberry-pi-cross-compilers)

**Using Raspberry Pi GCC 64-Bit Cross-Compiler Toolchains (Bullseye)**

 - **Host OS:** any x64/x86 Linux machine	
 - **Target OS:** Bullseye 64-bit OS (Debian Version 11) only	
 - **Status:**    Stable/Production	
 - **Version:** 10.2.0, **[10.3.0](https://sourceforge.net/projects/raspberry-pi-cross-compilers/files/Bonus%20Raspberry%20Pi%20GCC%2064-Bit%20Toolchains/Raspberry%20Pi%20GCC%2064-Bit%20Cross-Compiler%20Toolchains/Bullseye/GCC%2010.3.0/cross-gcc-10.3.0-pi_64.tar.gz/download)**

## Installation of TARGET

- Install RaspberryPI OS on your RASPBERRY instance
- connect it to network

## Installation of Compilation host

- run `./scripts/setup.sh`
- store user&host of your target-computer in file `SSHTARGET`
- store sshpassword of your target-computer in file `.sshpasswd`
- run the sync-script to sync the root-fs `./scripts/sync-with-target.sh`

## Run the example build

```bash
pushd src/example
./setup_buildsystem.sh
echo -e "\nResult:\n" `file build/cmake_test`
popd
```
- run `./scripts/setup.sh`
- store user&host of your target-computer in file `SSHTARGET`
