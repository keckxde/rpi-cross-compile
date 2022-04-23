TOOLCHAIN_FILE=../../PI.cmake
mkdir -p build
pushd build
cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}  -DCMAKE_BUILD_TYPE=Debug ..
make
popd
