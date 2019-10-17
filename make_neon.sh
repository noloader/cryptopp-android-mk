#!/usr/bin/env bash

# make_neon.sh copies *_simd.cpp files and names them
# with a .neon extension so Android's build system
# applies NEON flags when compiling them. In turn,
# Android.mk filters out the *_simd.cpp from the file
# list and adds the *.neon files to the file list.

# The original *_simd.cpp files are not deleted because
# they are still needed for other architectures like
# Aarch46 and x86_64.

for file in *_simd.cpp;
do
    cp "$file" "$file.neon"
done

rm ppc_simd.cpp.neon
rm sse_simd.cpp.neon
