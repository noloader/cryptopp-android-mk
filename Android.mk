## Android.mk - Android build file for Crypto++. Written and placed in
##              public domain by Jeffrey Walton. Based on Android.mk
##              by Alex Afanasyev (GitHub @cawka),
##              https://github.com/weidai11/cryptopp/pull/3
##
##              The Android make uses GNU Make and is documented at
##              https://developer.android.com/ndk/guides/android_mk
##              The CPU Features library is documented at
##              https://developer.android.com/ndk/guides/cpu-features
##
##              You can create the list of files below with:
##
##                  $ make sources | fold -w74 -s
##

ifeq ($(NDK_LOG),1)
    $(info Crypto++: TARGET_ARCH: $(TARGET_ARCH))
    $(info Crypto++: TARGET_PLATFORM: $(TARGET_PLATFORM))
endif

LOCAL_PATH := $(call my-dir)

#####################################################################
# Adjust CRYPTOPP_PATH to suit your taste, like ../cryptopp-7.1/.
# If CRYPTOPP_PATH is empty then it means the library files and the
# Android files are side-by-side in the same directory. If
# CRYPTOPP_PATH is not empty then must include the trailing slash.
# The trailing slash is needed because CRYPTOPP_PATH is prepended
# to each source file listed in CRYPTOPP_SRC_FILES.

# CRYPTOPP_PATH ?= ../cryptopp/
CRYPTOPP_PATH ?=

ifeq ($(NDK_LOG),1)
  ifeq ($CRYPTOPP_PATH),)
    $(info Crypto++: CRYPTOPP_PATH is empty)
  else
    $(info Crypto++: CRYPTOPP_PATH is $(CRYPTOPP_PATH))
  endif
endif

#####################################################################
# Library source files

CRYPTOPP_SRC_FILES := \
    cryptlib.cpp cpu.cpp integer.cpp 3way.cpp adler32.cpp algebra.cpp \
    algparam.cpp arc4.cpp aria-simd.cpp aria.cpp ariatab.cpp asn.cpp \
    authenc.cpp base32.cpp base64.cpp basecode.cpp bfinit.cpp blake2-simd.cpp \
    blake2.cpp blowfish.cpp blumshub.cpp camellia.cpp cast.cpp casts.cpp \
    cbcmac.cpp ccm.cpp chacha.cpp cham-simd.cpp cham.cpp channels.cpp \
    cmac.cpp crc-simd.cpp crc.cpp default.cpp des.cpp dessp.cpp dh.cpp \
    dh2.cpp dll.cpp dsa.cpp eax.cpp ec2n.cpp eccrypto.cpp ecp.cpp elgamal.cpp \
    emsa2.cpp eprecomp.cpp esign.cpp files.cpp filters.cpp fips140.cpp \
    fipstest.cpp gcm-simd.cpp gcm.cpp gf256.cpp gf2_32.cpp gf2n.cpp \
    gfpcrypt.cpp gost.cpp gzip.cpp hc128.cpp hc256.cpp hex.cpp hight.cpp \
    hmac.cpp hrtimer.cpp ida.cpp idea.cpp iterhash.cpp kalyna.cpp \
    kalynatab.cpp keccak.cpp keccakc.cpp lea-simd.cpp lea.cpp luc.cpp \
    mars.cpp marss.cpp md2.cpp md4.cpp md5.cpp misc.cpp modes.cpp mqueue.cpp \
    mqv.cpp nbtheory.cpp neon-simd.cpp oaep.cpp osrng.cpp padlkrng.cpp \
    panama.cpp pkcspad.cpp poly1305.cpp polynomi.cpp ppc-simd.cpp pssr.cpp \
    pubkey.cpp queue.cpp rabbit.cpp rabin.cpp randpool.cpp rc2.cpp rc5.cpp \
    rc6.cpp rdrand.cpp rdtables.cpp rijndael-simd.cpp rijndael.cpp ripemd.cpp \
    rng.cpp rsa.cpp rw.cpp safer.cpp salsa.cpp scrypt.cpp seal.cpp seed.cpp \
    serpent.cpp sha-simd.cpp sha.cpp sha3.cpp shacal2-simd.cpp shacal2.cpp \
    shark.cpp sharkbox.cpp simeck-simd.cpp simeck.cpp simon.cpp \
    simon128-simd.cpp simon64-simd.cpp skipjack.cpp sm3.cpp sm4-simd.cpp \
    sm4.cpp sosemanuk.cpp speck.cpp speck128-simd.cpp speck64-simd.cpp \
    square.cpp squaretb.cpp sse-simd.cpp strciphr.cpp tea.cpp tftables.cpp \
    threefish.cpp tiger.cpp tigertab.cpp ttmac.cpp tweetnacl.cpp twofish.cpp \
    vmac.cpp wake.cpp whrlpool.cpp xtr.cpp xtrcrypt.cpp zdeflate.cpp \
    zinflate.cpp zlib.cpp

#####################################################################
# Test source files

# Remove adhoc.cpp from this list

CRYPTOPP_TEST_FILES := \
    test.cpp bench1.cpp bench2.cpp bench3.cpp datatest.cpp \
    dlltest.cpp fipsalgt.cpp validat0.cpp validat1.cpp validat2.cpp \
    validat3.cpp validat4.cpp validat5.cpp validat6.cpp validat7.cpp \
    validat8.cpp validat9.cpp validat10.cpp regtest1.cpp regtest2.cpp \
    regtest3.cpp regtest4.cpp

#####################################################################
# ARM A-32 source file

ifeq ($(TARGET_ARCH),arm)
    CRYPTOPP_SRC_FILES += aes-armv4.S
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

#####################################################################
# Shared object

include $(CLEAR_VARS)
LOCAL_MODULE := cryptopp_shared
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_SRC_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDFLAGS := -Wl,--exclude-libs,ALL -Wl,--as-needed

LOCAL_EXPORT_CFLAGS := $(LOCAL_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/..

LOCAL_STATIC_LIBRARIES := cpufeatures

include $(BUILD_SHARED_LIBRARY)

#####################################################################
# Static library

include $(CLEAR_VARS)
LOCAL_MODULE := cryptopp_static
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_SRC_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

LOCAL_EXPORT_CFLAGS := $(LOCAL_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/..

LOCAL_STATIC_LIBRARIES := cpufeatures

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# Test program

include $(CLEAR_VARS)
LOCAL_MODULE := cryptest.exe
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_TEST_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDFLAGS := -Wl,--as-needed

LOCAL_STATIC_LIBRARIES := cryptopp_static
include $(BUILD_EXECUTABLE)

$(call import-module,android/cpufeatures)
