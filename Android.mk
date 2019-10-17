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

## TODO - We use this line below in the .mk file:
##            LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/..
## The open question is, should we be exporting the path as:
##            LOCAL_EXPORT_C_INCLUDES := $(CRYPTOPP_PATH)

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

#####################################################################
# Library source files

# The extra gyrations put cryptlib.cpp cpu.cpp integer.cpp at the head of
# the list so their static initializers run first. Sort is used for
# deterministic builds.

CRYPTOPP_INIT_FILES := cryptlib.cpp cpu.cpp integer.cpp
CRYPTOPP_ALL_FILES := $(sort $(filter-out adhoc.cpp,$(wildcard *.cpp)))
CRYPTOPP_SRC_FILES := $(filter-out $(CRYPTOPP_TEST_FILES),$(CRYPTOPP_ALL_FILES))
CRYPTOPP_SRC_FILES := $(filter-out $(CRYPTOPP_INIT_FILES),$(CRYPTOPP_SRC_FILES))
CRYPTOPP_LIB_FILES := $(CRYPTOPP_INIT_FILES) $(CRYPTOPP_SRC_FILES)

#####################################################################
# ARM A-32 source file

ifeq ($(TARGET_ARCH),arm)
    CRYPTOPP_ARM_FILES := aes_armv4.S sha1_armv4.S sha256_armv4.S sha512_armv4.S
    CRYPTOPP_LIB_FILES := $(CRYPTOPP_LIB_FILES) $(CRYPTOPP_ARM_FILES)
    LOCAL_ARM_MODE := arm
    LOCAL_FILTER_ASM :=
endif

# Hack because our NEON files do not have the *.neon extension
ifeq ($(TARGET_ARCH),arm)
    $(shell ./make_neon.sh)  # copies *_simd.cpp to *_simd.cpp.neon
    CRYPTOPP_NEON_FILES := $(sort $(wildcard *.cpp.neon))
    CRYPTOPP_LIB_FILES := $(filter-out %_simd.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(CRYPTOPP_LIB_FILES) $(CRYPTOPP_NEON_FILES)
endif

#####################################################################
# Remove other unneeded source files. Even Intel does not need AVX

ifeq ($(TARGET_ARCH),arm)
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out ppc_simd.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out sse_simd.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),arm64)
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out ppc_simd.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out sse_simd.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),x86)
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out neon_simd.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out ppc_simd.cpp,$(CRYPTOPP_LIB_FILES))
endif

ifeq ($(TARGET_ARCH),x86_64)
    CRYPTOPP_LIB_FILES := $(filter-out %_avx.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out neon_simd.cpp,$(CRYPTOPP_LIB_FILES))
    CRYPTOPP_LIB_FILES := $(filter-out ppc_simd.cpp,$(CRYPTOPP_LIB_FILES))
endif

#####################################################################
# Shared object

include $(CLEAR_VARS)
LOCAL_MODULE := cryptopp_shared
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_LIB_FILES))
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
LOCAL_SRC_FILES := $(addprefix $(CRYPTOPP_PATH),$(CRYPTOPP_LIB_FILES))
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

#####################################################################
# Android cpuFeatures library

$(call import-module,android/cpufeatures)

