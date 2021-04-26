## Android.mk - Android build file for Crypto++.
##
## Written and placed in public domain by Jeffrey Walton. This
## Android.mk is based on Alex Afanasyev (GitHub @cawka) PR #3,
## https://github.com/weidai11/cryptopp/pull/3.
##
## The Android build system is a wrapper around GNU Make and is
## documented https://developer.android.com/ndk/guides/android_mk.
## The CPU Features library provides caps and is documented at
## https://developer.android.com/ndk/guides/cpu-features.
##
## At Crypto++ 8.5 we added test_shared.hxx and test_shared.cxx to
## produce libtest_shared.so. The test_shared recipe shows you how
## to build a simple shared object, if desired. A couple wiki pages
## refers to it for demonstration purposes. The test_shared recipe
## can be deleted at any time.
##
## At Crypto++ 8.6 we used architecture specific flags like in the
## makefile. The arch specific flags complicated Android.mk because
## we have to build a local library for each source file with an
## arch option. To see Android.mk before the changes checkout
## CRYPTOPP_8_5_0 tag. If you don't want to build like Android.mk
## does, then add -DCRYPTOPP_DISABLE_ANDROID_ADVANCED_ISA=1 to
## CPPFLAGS. The define disables the advanced ISA code paths used
## by Android.
##
## The library's makefile and the 'make distclean' recipe will
## clean the artifacts created by Android.mk, like obj/,
## neon_simd.cpp.neon and rijndael_simd.cpp.neon.

ifeq ($(NDK_LOG),1)
    $(info Crypto++: TARGET_ARCH: $(TARGET_ARCH))
    $(info Crypto++: TARGET_PLATFORM: $(TARGET_PLATFORM))
endif

LOCAL_PATH := $(call my-dir)

# Check for the test_shared source files. If present,
# build the test shared object.
ifneq ($(wildcard test_shared.hxx),)
  ifneq ($(wildcard test_shared.cxx),)
    $(info Crypto++: enabling test shared object)
    TEST_SHARED_PROJECT := 1
  endif
endif

#####################################################################
# Adjust CRYPTOPP_PATH to suit your taste, like ../cryptopp-7.1/.
# If CRYPTOPP_PATH is empty then it means the library files and the
# Android files are side-by-side in the same directory. If
# CRYPTOPP_PATH is not empty then must include the trailing slash.
# The trailing slash is needed because CRYPTOPP_PATH is prepended
# to each source file listed in CRYPTOPP_LIB_FILES.

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
# Test source files

# Remove adhoc.cpp from this list

CRYPTOPP_TEST_FILES := \
    test.cpp bench1.cpp bench2.cpp bench3.cpp datatest.cpp \
    dlltest.cpp fipsalgt.cpp validat0.cpp validat1.cpp validat2.cpp \
    validat3.cpp validat4.cpp validat5.cpp validat6.cpp validat7.cpp \
    validat8.cpp validat9.cpp validat10.cpp regtest1.cpp regtest2.cpp \
    regtest3.cpp regtest4.cpp

CRYPTOPP_TEST_FILES := $(filter-out adhoc.cpp,$(CRYPTOPP_TEST_FILES))

#####################################################################
# Library source files

# The extra gyrations put cryptlib.cpp cpu.cpp integer.cpp at the head
# of the list so their static initializers run first. Sort is used for
# deterministic builds.

CRYPTOPP_INIT_FILES := cryptlib.cpp cpu.cpp integer.cpp
CRYPTOPP_ALL_FILES := $(sort $(filter-out adhoc.cpp,$(wildcard *.cpp)))
CRYPTOPP_LIB_FILES := $(filter-out $(CRYPTOPP_TEST_FILES),$(CRYPTOPP_ALL_FILES))
CRYPTOPP_LIB_FILES := $(filter-out $(CRYPTOPP_INIT_FILES),$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(CRYPTOPP_INIT_FILES) $(CRYPTOPP_LIB_FILES)

#####################################################################
# ARM A-32 source files

ifeq ($(TARGET_ARCH),arm)
    CRYPTOPP_ARM_FILES := aes_armv4.S sha1_armv4.S sha256_armv4.S sha512_armv4.S
    CRYPTOPP_LIB_FILES := $(CRYPTOPP_LIB_FILES) $(CRYPTOPP_ARM_FILES)
endif

#####################################################################
# Remove unneeded arch specific source files

CRYPTOPP_LIB_FILES := $(filter-out ppc_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out neon_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out sse_simd.cpp,$(CRYPTOPP_LIB_FILES))

ifeq ($(TARGET_ARCH),arm)
    CRYPTOPP_LIB_FILES := $(filter-out donna_64.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),arm64)
    CRYPTOPP_LIB_FILES := $(filter-out donna_32.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),x86)
    CRYPTOPP_LIB_FILES := $(filter-out donna_64.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),x86_64)
    CRYPTOPP_LIB_FILES := $(filter-out donna_32.cpp,$(CRYPTOPP_LIB_FILES))
endif

#####################################################################
# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

CRYPTOPP_LIB_FILES := $(filter-out aria_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out blake2b_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out blake2s_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out chacha_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out chacha_avx.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out crc_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out gcm_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out gf2n_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out lea_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out lsh256_sse.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out lsh512_sse.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out lsh256_avx.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out lsh512_avx.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out rijndael_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out sm4_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out sha_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out shacal2_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out simon128_simd.cpp,$(CRYPTOPP_LIB_FILES))
CRYPTOPP_LIB_FILES := $(filter-out speck128_simd.cpp,$(CRYPTOPP_LIB_FILES))

ifeq ($(NDK_LOG),1)
    $(info CRYPTOPP_LIB_FILES ($(TARGET_ARCH)): $(CRYPTOPP_LIB_FILES))
endif

#####################################################################
# ARIA using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_aria
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),aria_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# BLAKE2s using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_blake2s
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),blake2s_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# BLAKE2b using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_blake2b
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),blake2b_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# ChaCha using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_chacha
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),chacha_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse2
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# ChaCha using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

ifneq ($(filter x86 x86_64,$(TARGET_ARCH)),)

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_chacha_avx
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),chacha_avx.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mavx2
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mavx2
endif

CRYPTOPP_CHACHA_AVX := cryptopp_chacha_avx

include $(BUILD_STATIC_LIBRARY)

endif

#####################################################################
# LEA using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_lea
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),lea_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# LSH256 and LSH512 using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

ifneq ($(filter x86 x86_64,$(TARGET_ARCH)),)

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_lsh256_sse
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),lsh256_sse.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mssse3

CRYPTOPP_LSH256_SSE := cryptopp_lsh256_sse

include $(BUILD_STATIC_LIBRARY)

#####################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_lsh512_sse
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),lsh512_sse.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mssse3

CRYPTOPP_LSH512_SSE := cryptopp_lsh512_sse

include $(BUILD_STATIC_LIBRARY)

#####################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_lsh256_avx
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),lsh256_avx.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mavx2

CRYPTOPP_LSH256_AVX := cryptopp_lsh256_avx

include $(BUILD_STATIC_LIBRARY)

#####################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_lsh512_avx
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),lsh512_avx.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mavx2

CRYPTOPP_LSH512_AVX := cryptopp_lsh512_avx

include $(BUILD_STATIC_LIBRARY)

endif

#####################################################################
# NEON using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

ifneq ($(filter arm arm64,$(TARGET_ARCH)),)

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_neon
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),neon_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
endif

include $(BUILD_STATIC_LIBRARY)

CRYPTOPP_NEON := cryptopp_neon

endif

#####################################################################
# CRC using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_crc
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),crc_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crc
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.2
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.2
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# AES using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_rijndael
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),rijndael_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -maes
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -maes
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SM4 using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_sm4
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),sm4_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -maes
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -maes
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# GCM using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_gcm
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),gcm_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mpclmul
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mpclmul
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# GF2N using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_gf2n
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),gf2n_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mpclmul
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -mpclmul
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SHA using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_sha
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),sha_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -msha
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -msha
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SHACAL2 using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_shacal2
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),shacal2_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv8-a+crypto
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -msha
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1 -msha
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SIMON using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_simon
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),simon128_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SPECK using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_speck
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),speck128_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -march=armv7-a -mfpu=neon
else ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
else ifeq ($(TARGET_ARCH),x86_64)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse4.1
endif

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# SSE using specific ISA.

# Hack because Android.mk does not allow us to specify arch options
# during compile of a source file. Instead, we have to build a
# local library with the arch options.
# https://github.com/weidai11/cryptopp/issues/1015

ifneq ($(filter x86 x86_64,$(TARGET_ARCH)),)

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_sse
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),sse_simd.cpp)
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),x86)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -msse2
endif

include $(BUILD_STATIC_LIBRARY)

CRYPTOPP_SSE := cryptopp_sse

endif

#####################################################################
# Static library

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_static
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_LIB_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions

ifeq ($(TARGET_ARCH),arm)
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

# Configure for release unless NDK_DEBUG=1
ifeq ($(NDK_DEBUG),1)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DDEBUG
else
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DNDEBUG
endif

# Include all the local libraries for arch specific compiles.
# https://github.com/weidai11/cryptopp/issues/1015
LOCAL_STATIC_LIBRARIES := cpufeatures \
    cryptopp_aria \
    cryptopp_blake2s cryptopp_blake2b \
    cryptopp_chacha $(CRYPTOPP_CHACHA_AVX) \
    cryptopp_crc \
    cryptopp_gcm cryptopp_gf2n \
    cryptopp_lea $(CRYPTOPP_NEON) \
    cryptopp_rijndael cryptopp_sm4 \
    $(CRYPTOPP_LSH256_SSE) $(CRYPTOPP_LSH256_AVX) \
    $(CRYPTOPP_LSH512_SSE) $(CRYPTOPP_LSH512_AVX) \
    cryptopp_sha cryptopp_shacal2 \
    cryptopp_simon cryptopp_speck \
    $(CRYPTOPP_SSE)

include $(BUILD_STATIC_LIBRARY)

#####################################################################
# Shared object

include $(CLEAR_VARS)

LOCAL_MODULE := cryptopp_shared
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_LIB_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDFLAGS := -Wl,--gc-sections -Wl,--exclude-libs,ALL -Wl,--as-needed

ifeq ($(TARGET_ARCH),arm)
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

# Configure for release unless NDK_DEBUG=1
ifeq ($(NDK_DEBUG),1)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DDEBUG
else
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DNDEBUG
endif

# Include all the local libraries for arch specific compiles.
# https://github.com/weidai11/cryptopp/issues/1015
LOCAL_STATIC_LIBRARIES := cpufeatures \
    cryptopp_aria \
    cryptopp_blake2s cryptopp_blake2b \
    cryptopp_chacha $(CRYPTOPP_CHACHA_AVX) \
    cryptopp_crc \
    cryptopp_gcm cryptopp_gf2n \
    cryptopp_lea $(CRYPTOPP_NEON) \
    $(CRYPTOPP_LSH256_SSE) $(CRYPTOPP_LSH256_AVX) \
    $(CRYPTOPP_LSH512_SSE) $(CRYPTOPP_LSH512_AVX) \
    cryptopp_rijndael cryptopp_sm4 \
    cryptopp_sha cryptopp_shacal2 \
    cryptopp_simon cryptopp_speck \
    $(CRYPTOPP_SSE)

include $(BUILD_SHARED_LIBRARY)

#####################################################################
# Test shared object

# This recipe is for demonstration purposes. It shows you how to
# build your own shared object. It is OK to delete this recipe and
# the source files test_shared.hxx and test_shared.cxx.

ifeq ($(TEST_SHARED_PROJECT),1)

include $(CLEAR_VARS)

LOCAL_MODULE := test_shared
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),test_shared.cxx)
LOCAL_CPPFLAGS := -Wall -fvisibility=hidden
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDFLAGS := -Wl,--gc-sections -Wl,--exclude-libs,ALL -Wl,--as-needed

ifeq ($(TARGET_ARCH),arm)
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

# Configure for release unless NDK_DEBUG=1
ifeq ($(NDK_DEBUG),1)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DDEBUG
else
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DNDEBUG
endif

LOCAL_STATIC_LIBRARIES := cryptopp_static

include $(BUILD_SHARED_LIBRARY)

endif

#####################################################################
# Test program

include $(CLEAR_VARS)

LOCAL_MODULE := cryptest.exe
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_TEST_FILES))
LOCAL_CPPFLAGS := -Wall
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDFLAGS := -Wl,--gc-sections -Wl,--as-needed

ifeq ($(TARGET_ARCH),arm)
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

# Configure for release unless NDK_DEBUG=1
ifeq ($(NDK_DEBUG),1)
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DDEBUG
else
    LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -DNDEBUG
endif

LOCAL_STATIC_LIBRARIES := cryptopp_static

include $(BUILD_EXECUTABLE)

#####################################################################
# Android cpuFeatures library

$(call import-module,android/cpufeatures)
