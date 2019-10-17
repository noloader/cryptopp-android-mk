#!/usr/bin/env bash

for file in *_simd.cpp;
do
    cp "$file" "$file.neon"
done

rm ppc_simd.cpp.neon
rm sse_simd.cpp.neon

