#ifndef CRYPTOPP_TEST_SHARED
#define CRYPTOPP_TEST_SHARED

#include <stdint.h>

#if __GNUC__ >= 4
  #define DLL_PUBLIC __attribute__ ((visibility ("default")))
  #define DLL_LOCAL  __attribute__ ((visibility ("hidden")))
#else
  #define DLL_PUBLIC
  #define DLL_LOCAL
#endif

extern "C" DLL_PUBLIC
int sha1_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize);

extern "C" DLL_PUBLIC
int sha256_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize);

extern "C" DLL_PUBLIC
int sha512_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize);

#endif  // CRYPTOPP_TEST_SHARED