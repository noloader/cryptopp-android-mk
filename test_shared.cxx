#include <test_shared.hxx>
#include <cryptlib.h>
#include <sha.h>
#include <stdint.h>

extern "C" DLL_PUBLIC
int sha1_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize)
{
    using CryptoPP::SHA1;
    using CryptoPP::Exception;

    try
    {
        SHA1().CalculateTruncatedDigest(digest, dsize, message, msize);
        return 0;  // success
    }
    catch(const Exception&)
    {
        return 1;  // failure
    }
}

extern "C" DLL_PUBLIC
int sha256_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize)
{
    using CryptoPP::SHA256;
    using CryptoPP::Exception;

    try
    {
        SHA256().CalculateTruncatedDigest(digest, dsize, message, msize);
        return 0;  // success
    }
    catch(const Exception&)
    {
        return 1;  // failure
    }
}

extern "C" DLL_PUBLIC
int sha512_hash(uint8_t* digest, size_t dsize, const uint8_t* message, size_t msize)
{
    using CryptoPP::SHA512;
    using CryptoPP::Exception;

    try
    {
        SHA512().CalculateTruncatedDigest(digest, dsize, message, msize);
        return 0;  // success
    }
    catch(const Exception&)
    {
        return 1;  // failure
    }
}
