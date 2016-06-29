#ifndef __CX_H
#define __CX_H


#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


#include <stddef.h>

#include "misc_types.h"


enum {  CX_MAX_SERVER = 60  }; /* Max N of CX_INET_PORT+N */

enum {CX_NULL_CHANID = 0}; // Nonexistent/unbound channel ID


/*====================================================================
|                                                                    |
|  Common types                                                      |
|                                                                    |
====================================================================*/

typedef int32  cxid_t;

typedef cxid_t chanaddr_t;
typedef uint32 rflags_t;
typedef uint8  cxdtype_t;

typedef int32  cx_ival_t;
typedef int64  cx_lval_t;
typedef double cx_dval_t;

typedef struct
{
    long  sec;
    long  nsec;
} cx_time_t;

enum
{
    CX_TIME_SEC_TRUSTED    = 0,
    CX_TIME_SEC_NEVER_READ = 1,
};


/*
 *  cxdtype_t management
 */

enum
{
    /* Encoding scheme */
    CXDTYPE_SIZE_MASK = 0x7,
    CXDTYPE_REPR_MASK = 0x78, CXDTYPE_REPR_SHIFT = 3,
    CXDTYPE_USGN_MASK = 0x80,

    /* Representations */
    CXDTYPE_REPR_UNKNOWN = 0,
    CXDTYPE_REPR_INT     = 1,
    CXDTYPE_REPR_FLOAT   = 2,
    CXDTYPE_REPR_TEXT    = 3,
};

#define ENCODE_DTYPE(bytesize, repr, usgn) \
    ((cxdtype_t)(                          \
    (                                      \
       bytesize==1? 0                      \
     :(bytesize==2? 1                      \
     :(bytesize==4? 2                      \
     :(bytesize==8? 3                      \
     :              7)))                   \
    )                                      \
    | (repr << CXDTYPE_REPR_SHIFT)         \
    | (usgn? CXDTYPE_USGN_MASK : 0)        \
    ))

enum
{
    CXDTYPE_UNKNOWN = ENCODE_DTYPE(sizeof(int8),    CXDTYPE_REPR_UNKNOWN, 0),

    CXDTYPE_INT8    = ENCODE_DTYPE(sizeof(int8),    CXDTYPE_REPR_INT,     0),
    CXDTYPE_INT16   = ENCODE_DTYPE(sizeof(int16),   CXDTYPE_REPR_INT,     0),
    CXDTYPE_INT32   = ENCODE_DTYPE(sizeof(int32),   CXDTYPE_REPR_INT,     0),
    CXDTYPE_INT64   = ENCODE_DTYPE(sizeof(int64),   CXDTYPE_REPR_INT,     0),
    CXDTYPE_UINT8   = ENCODE_DTYPE(sizeof(uint8),   CXDTYPE_REPR_INT,     1),
    CXDTYPE_UINT16  = ENCODE_DTYPE(sizeof(uint16),  CXDTYPE_REPR_INT,     1),
    CXDTYPE_UINT32  = ENCODE_DTYPE(sizeof(uint32),  CXDTYPE_REPR_INT,     1),
    CXDTYPE_UINT64  = ENCODE_DTYPE(sizeof(uint64),  CXDTYPE_REPR_INT,     1),

    CXDTYPE_SINGLE  = ENCODE_DTYPE(sizeof(float32), CXDTYPE_REPR_FLOAT,   0),
    CXDTYPE_DOUBLE  = ENCODE_DTYPE(sizeof(float64), CXDTYPE_REPR_FLOAT,   0),

    CXDTYPE_TEXT    = ENCODE_DTYPE(1,               CXDTYPE_REPR_TEXT,    1),
    CXDTYPE_UCTEXT  = ENCODE_DTYPE(4,               CXDTYPE_REPR_TEXT,    1),
};

static inline size_t sizeof_cxdtype(cxdtype_t t)
{
    return 1 << (t & CXDTYPE_SIZE_MASK);
}

static inline int    reprof_cxdtype(cxdtype_t t)
{
    return (t & CXDTYPE_REPR_MASK) >> CXDTYPE_REPR_SHIFT;
}


/*
 *  Note: when adding/changing flags, the
 *  lib/cxlib/cxlib_utils.c::_cx_rflagslist[] must be updated coherently.
 */
enum
{
    CXRF_SERVER_MASK       = 0x0000FFFF,
    CXRF_CLIENT_MASK       = 0xFFFF0000,

    /* Server-side flags -- CXRF_* */
    CXRF_CAMAC_NO_X        = 1 << 0,  // No 'X' from device
    CXRF_CAMAC_NO_Q        = 1 << 1,  // No 'Q' from device

    CXRF_IO_TIMEOUT        = 1 << 2,  // I/O timeout expired
    CXRF_REM_C_PROBL       = 1 << 3,  // Remote controller problem

    CXRF_OVERLOAD          = 1 << 4,  // Input channel overload

    CXRF_UNSUPPORTED       = 1 << 5,  // Unsupported feature/channel
    
    CXRF_INVAL             = 1 << 10, // Invalid parameter
    CXRF_WRONG_DEV         = 1 << 11, // Wrong device
    CXRF_CFG_PROBL         = 1 << 12, // Configuration problem
    CXRF_DRV_PROBL         = 1 << 13, // Driver internal problem
    CXRF_NO_DRV            = 1 << 14, // Driver loading problem
    CXRF_OFFLINE           = 1 << 15, // Device is offline

    CXRF_SERVER_HWERR_MASK =
        CXRF_CAMAC_NO_X  |
        CXRF_CAMAC_NO_Q  |
        CXRF_IO_TIMEOUT  |
        CXRF_REM_C_PROBL |
        CXRF_OVERLOAD    |
        CXRF_UNSUPPORTED,
    CXRF_SERVER_SFERR_MASK = CXRF_SERVER_MASK &~ CXRF_SERVER_HWERR_MASK,

    /* Client-side flags -- CXCF_* */
    /* cda -- upwards from 16 */
    CXCF_FLAG_CALCERR      = 1 << 16, // Formula calculation error
    CXCF_FLAG_DEFUNCT      = 1 << 17, // Defunct channel
    CXCF_FLAG_OTHEROP      = 1 << 18, // Other operator is active
    CXCF_FLAG_PRGLYCHG     = 1 << 19, // Channel was programmatically changed
    CXCF_FLAG_NOTFOUND     = 1 << 20, // Channel not found
    CXCF_FLAG_COLOR_WEIRD  = 1 << 21, // Value is weird

    CXCF_FLAG_CDA_MASK     =
        CXCF_FLAG_CALCERR     |
        CXCF_FLAG_DEFUNCT     |
        CXCF_FLAG_OTHEROP     |
        CXCF_FLAG_PRGLYCHG    |
        CXCF_FLAG_NOTFOUND    |
        CXCF_FLAG_COLOR_WEIRD,

    /* Cdr -- downwards from 31 */
    CXCF_FLAG_ALARM_ALARM  = 1 << 31, // Alarm!
    CXCF_FLAG_ALARM_RELAX  = 1 << 30, // Relaxing after alarm
    CXCF_FLAG_COLOR_RED    = 1 << 29, // Value in red zone
    CXCF_FLAG_COLOR_YELLOW = 1 << 28, // Value in yellow zone

    CXCF_FLAG_CDR_MASK     =
        CXCF_FLAG_ALARM_ALARM  |
        CXCF_FLAG_ALARM_RELAX  |
        CXCF_FLAG_COLOR_RED    |
        CXCF_FLAG_COLOR_YELLOW,

    /* General classification */
    CXCF_FLAG_HWERR_MASK   = CXRF_SERVER_HWERR_MASK,
    CXCF_FLAG_SFERR_MASK   = CXRF_SERVER_SFERR_MASK | CXCF_FLAG_CALCERR,
    CXCF_FLAG_SYSERR_MASK  =
        CXCF_FLAG_HWERR_MASK |
        CXCF_FLAG_SFERR_MASK |
        CXCF_FLAG_DEFUNCT    |
        CXCF_FLAG_NOTFOUND,

    CXCF_FLAG_ALARM_MASK   = CXCF_FLAG_ALARM_ALARM | CXCF_FLAG_ALARM_RELAX,
    CXCF_FLAG_COLOR_MASK   =
        CXCF_FLAG_COLOR_WEIRD  |
        CXCF_FLAG_COLOR_RED    |
        CXCF_FLAG_COLOR_YELLOW,
        
    CXCF_FLAG_4WRONLY_MASK = CXCF_FLAG_OTHEROP | CXCF_FLAG_PRGLYCHG,
};

enum
{
    CX_VALUE_LIT_MASK      = 1 << 0,
    CX_VALUE_DISABLED_MASK = 1 << 1,

    CX_VALUE_COMMAND       = 1,
};


enum
{
    CX_LOCK_RD = 1,
    CX_LOCK_WR = 2,
    CX_LOCK_ALLORNOTHING = 1 << 7,
};


#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* __CX_H */
