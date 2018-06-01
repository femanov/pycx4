
from misc_types cimport uint8, uint32, int32, int64


cdef extern from "cx.h" nogil:
    ctypedef uint32 rflags_t
    ctypedef uint8  cxdtype_t

    ctypedef int32  cx_ival_t
    ctypedef int64  cx_lval_t
    ctypedef double cx_dval_t

    ctypedef struct cx_time_t:
        int sec
        int nsec


    enum:
        CXDTYPE_SIZE_MASK
        CXDTYPE_REPR_MASK
        CXDTYPE_REPR_SHIFT
        CXDTYPE_USGN_MASK

        #/* Representations */
        CXDTYPE_REPR_UNKNOWN
        CXDTYPE_REPR_INT
        CXDTYPE_REPR_FLOAT
        CXDTYPE_REPR_TEXT

    enum:
        CXDTYPE_UNKNOWN
        CXDTYPE_INT8
        CXDTYPE_INT16
        CXDTYPE_INT32
        CXDTYPE_INT64
        CXDTYPE_UINT8
        CXDTYPE_UINT16
        CXDTYPE_UINT32
        CXDTYPE_UINT64
        CXDTYPE_SINGLE
        CXDTYPE_DOUBLE
        CXDTYPE_TEXT
        CXDTYPE_UCTEXT

    size_t sizeof_cxdtype(cxdtype_t t)
    int    reprof_cxdtype(cxdtype_t t)


    enum: # flags
        CXRF_SERVER_MASK
        CXRF_CLIENT_MASK

        #/* Server-side flags -- CXRF_* */
        CXRF_CAMAC_NO_X       #// No 'X' from device
        CXRF_CAMAC_NO_Q       #// No 'Q' from device

        CXRF_IO_TIMEOUT       #// I/O timeout expired
        CXRF_REM_C_PROBL      #// Remote controller problem

        CXRF_OVERLOAD         #// Input channel overload

        CXRF_UNSUPPORTED      #// Unsupported feature/channel

        CXRF_INVAL            #// Invalid parameter
        CXRF_WRONG_DEV        #// Wrong device
        CXRF_CFG_PROBL        #// Configuration problem
        CXRF_DRV_PROBL        #// Driver internal problem
        CXRF_NO_DRV           #// Driver loading problem
        CXRF_OFFLINE          #// Device is offline

        CXRF_SERVER_HWERR_MASK
        CXRF_SERVER_SFERR_MASK

        #/* Client-side flags -- CXCF_* */
        #/* cda -- upwards from 16 */
        CXCF_FLAG_CALCERR     #// Formula calculation error
        CXCF_FLAG_DEFUNCT     #// Defunct channel
        CXCF_FLAG_OTHEROP     #// Other operator is active
        CXCF_FLAG_PRGLYCHG    #// Channel was programmatically changed
        CXCF_FLAG_NOTFOUND    #// Channel not found
        CXCF_FLAG_COLOR_WEIRD #// Value is weird

        CXCF_FLAG_CDA_MASK

        #/* Cdr -- downwards from 31 */
        CXCF_FLAG_ALARM_ALARM  #// Alarm!
        CXCF_FLAG_ALARM_RELAX  #// Relaxing after alarm
        CXCF_FLAG_COLOR_RED    #// Value in red zone
        CXCF_FLAG_COLOR_YELLOW #// Value in yellow zone

        CXCF_FLAG_CDR_MASK

        #/* General classification */
        CXCF_FLAG_HWERR_MASK
        CXCF_FLAG_SFERR_MASK
        CXCF_FLAG_SYSERR_MASK
        CXCF_FLAG_ALARM_MASK
        CXCF_FLAG_COLOR_MASK
        CXCF_FLAG_4WRONLY_MASK

    enum:
        CX_VALUE_LIT_MASK
        CX_VALUE_DISABLED_MASK
        CX_VALUE_COMMAND

    enum:
        CX_LOCK_RD
        CX_LOCK_WR
        CX_LOCK_ALLORNOTHING
