#!/usr/bin/env bash

# ====================================================================
# Tests Android cross-compiles using Android.mk
#
# Crypto++ Library is copyrighted as a compilation and (as of version 5.6.2)
# licensed under the Boost Software License 1.0, while the individual files
# in the compilation are all public domain.
#
# See http://www.cryptopp.com/wiki/Android.mk_(Command_Line) for more details
# ====================================================================

# set -x

# Temp directory
if [[ -z "$TMPDIR" ]]; then
    TMPDIR="$HOME/tmp"
    mkdir "$TMPDIR"
fi

if [[ ! -f cryptopp820.zip ]] || [[ ! -f cryptopp820.zip.sig ]]; then
    echo "Crypto++ zip file and signature file are missing."
    echo "Did something delete them, like on some versions of Debian?"
    exit 1
fi

# Check the signature if GnuPG is present
if [[ -n $(command -v gpg) ]]; then
    if gpg --quiet --verify cryptopp820.zip.sig cryptopp820.zip 2>/dev/null; then
        echo "Verified signature on cryptopp820.zip."
    else
        echo "Failed to verify signature on cryptopp820.zip."
        echo "Is the public key available?"
        echo "Also see https://www.cryptopp.com/wiki/Release_Signing."
    fi
else
    echo "GnuPG is missing. Skipping signature check."
fi

# Unpack the Crypto++ 8.2 release zip
echo "Unpacking cryptopp820.zip"
unzip -aoq cryptopp820.zip -d .

# Crypto++ Master
echo "Downloading setenv-android.sh"
if ! curl -o setenv-android.sh --silent --insecure "https://raw.githubusercontent.com/weidai11/cryptopp/master/TestScripts/setenv-android.sh"; then
    echo "setenv-android.sh download failed"
    exit 1
fi

# Crypto++ Master
echo "Downloading GNUmakefile-cross"
if ! curl -o GNUmakefile-cross --silent --insecure "https://raw.githubusercontent.com/weidai11/cryptopp/master/GNUmakefile-cross"; then
    echo "GNUmakefile-cross download failed"
    exit 1
fi

# Android.mk
echo "Copying Android.mk"
cp ../Android.mk .

# Application.mk
echo "Copying Application.mk"
cp ../Application.mk .

# make_neon.sh
echo "Copying make_neon.sh"
cp ../make_neon.sh .

# Fix perms
chmod +x setenv-android.sh
chmod +x make_neon.sh
chmod +x GNUmakefile-cross

# Fix quarantine on OS X
if [[ -n $(command -v xattr) ]]; then
    xattr -d "com.apple.quarantine" setenv-android.sh
    xattr -d "com.apple.quarantine" make_neon.sh
    xattr -d "com.apple.quarantine" make_neon.sh
fi

# Fix config.h
echo "Patching config.h"
sed -i 's|// #define CRYPTOPP_DISABLE_MIXED_ASM|#define CRYPTOPP_DISABLE_MIXED_ASM|g' config.h
sed -i '607i#undef CRYPTOPP_AVX_AVAILABLE' config.h
sed -i '608i#undef CRYPTOPP_AVX2_AVAILABLE' config.h

# Delete lines 86-92 in Android.mk
echo "Patching Android.mk"
sed -i -e '86,92d' Android.mk
sed -i -e '107d' Android.mk

# Delete most of line 636 in GNUmakefile-cross
echo "Patching GNUmakefile-cross"
sed -i 's/SRCS += aes_armv4.S sha1_armv4.S sha256_armv4.S sha512_armv4.S/SRCS += aes_armv4.S/g' GNUmakefile-cross

echo ""
echo "===================================================================="
echo ""

# Cleanup old artifacts
rm -rf "$TMPDIR/build.failed" 2>/dev/null
rm -rf "$TMPDIR/build.log" 2>/dev/null

# Use all platforms
PLATFORMS=(armeabi-v7a arm64-v8a x86 x86_64)

# Thank god... one runtime and one compiler
RUNTIMES=(libc++)

# Clean all artifacts
make distclean &>/dev/null
rm -rf objs/

for platform in "${PLATFORMS[@]}"
do
    # run in subshell to discard envar changes
    (
        source ./setenv-android.sh "$platform" # > /dev/null 2>&1
        if ndk-build NDK_PROJECT_PATH="$PWD" NDK_APPLICATION_MK="$PWD/Application.mk" V=1
        then
            echo "$platform:$runtime ==> SUCCESS" >> "$TMPDIR/build.log"
        else
            echo "$platform:$runtime ==> FAILURE" >> "$TMPDIR/build.log"
            touch "$TMPDIR/build.failed"
        fi
    )

    echo ""
    echo "===================================================================="
done

echo ""
echo "===================================================================="
echo "Dumping build results"
cat "$TMPDIR/build.log"

# let the script fail if any of the builds failed
if [ -f "$TMPDIR/build.failed" ]; then
    exit 1
fi

exit 0

