mkdir -p build
pushd build
cmake -DCMAKE_TOOLCHAIN_FILE=~/work/crosscompile/PI.cmake  -DCMAKE_BUILD_TYPE=Debug ..

popd
