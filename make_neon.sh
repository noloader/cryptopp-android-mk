#!/usr/bin/env bash

for file in *_simd.cpp;
do
    cp "$file" "$file.neon"
done

