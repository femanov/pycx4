
        # CXRF_SERVER_MASK
        # CXRF_CLIENT_MASK
        #
        # #/* Server-side flags -- CXRF_* */
        # CXRF_CAMAC_NO_X       #// No 'X' from device
        # CXRF_CAMAC_NO_Q       #// No 'Q' from device
        #
        # CXRF_IO_TIMEOUT       #// I/O timeout expired
        # CXRF_REM_C_PROBL      #// Remote controller problem
        #
        # CXRF_OVERLOAD         #// Input channel overload
        #
        # CXRF_UNSUPPORTED      #// Unsupported feature/channel
        #
        # CXRF_INVAL            #// Invalid parameter
        # CXRF_WRONG_DEV        #// Wrong device
        # CXRF_CFG_PROBL        #// Configuration problem
        # CXRF_DRV_PROBL        #// Driver internal problem
        # CXRF_NO_DRV           #// Driver loading problem
        # CXRF_OFFLINE          #// Device is offline
        #
        # CXRF_SERVER_HWERR_MASK
        # CXRF_SERVER_SFERR_MASK
        #
        # #/* Client-side flags -- CXCF_* */
        # #/* cda -- upwards from 16 */
        # CXCF_FLAG_CALCERR     #// Formula calculation error
        # CXCF_FLAG_DEFUNCT     #// Defunct channel
        # CXCF_FLAG_OTHEROP     #// Other operator is active
        # CXCF_FLAG_PRGLYCHG    #// Channel was programmatically changed
        # CXCF_FLAG_NOTFOUND    #// Channel not found
        # CXCF_FLAG_COLOR_WEIRD #// Value is weird
        #
        # CXCF_FLAG_CDA_MASK
        #
        # #/* Cdr -- downwards from 31 */
        # CXCF_FLAG_ALARM_ALARM  #// Alarm!
        # CXCF_FLAG_ALARM_RELAX  #// Relaxing after alarm
        # CXCF_FLAG_COLOR_RED    #// Value in red zone
        # CXCF_FLAG_COLOR_YELLOW #// Value in yellow zone
        #
        # CXCF_FLAG_CDR_MASK
        #
        # #/* General classification */
        # CXCF_FLAG_HWERR_MASK
        # CXCF_FLAG_SFERR_MASK
        # CXCF_FLAG_SYSERR_MASK
        #
        # CXCF_FLAG_ALARM_MASK
        # CXCF_FLAG_COLOR_MASK
        # CXCF_FLAG_COLOR_WEIRD
        # CXCF_FLAG_COLOR_RED
        # CXCF_FLAG_COLOR_YELLOW
        #
        # CXCF_FLAG_4WRONLY_MASK


cdef list text_flags(cx.rflags_t rflags):
    ret = []
    if (rflags & cx.CXRF_CAMAC_NO_X) > 0:
        ret.append('No X from CAMAC device')

    if (rflags & cx.CXRF_CAMAC_NO_Q) > 0:
        ret.append('No Q from CAMAC device')

    if (rflags & cx.CXRF_IO_TIMEOUT) > 0:
        ret.append('I/O timeout expired')

    if (rflags & cx.CXRF_REM_C_PROBL) > 0:
        ret.append('Remote controller problem')

    if (rflags & cx.CXRF_OVERLOAD) > 0:
        ret.append('Input channel overload')

    if (rflags & cx.CXRF_UNSUPPORTED) > 0:
        ret.append('Unsupported feature/channel')

    if (rflags & cx.CXRF_INVAL) > 0:
        ret.append('Invalid parameter')

    if (rflags & cx.CXRF_WRONG_DEV) > 0:
        ret.append('Wrong device')

    if (rflags & cx.CXRF_CFG_PROBL) > 0:
        ret.append('Configuration problem')

    if (rflags & cx.CXRF_DRV_PROBL) > 0:
        ret.append('Driver internal problem')

    if (rflags & cx.CXRF_NO_DRV) > 0:
        ret.append('Driver loading problem')

    if (rflags & cx.CXRF_OFFLINE) > 0:
        ret.append('Device is offline')

    if (rflags & cx.CXCF_FLAG_CALCERR) > 0:
        ret.append('Formula calculation error')

    if (rflags & cx.CXCF_FLAG_DEFUNCT) > 0:
        ret.append('Defunct channel')

    if (rflags & cx.CXCF_FLAG_OTHEROP) > 0:
        ret.append('Other operator is active')

    if (rflags & cx.CXCF_FLAG_PRGLYCHG) > 0:
        ret.append('Channel was programmatically changed')

    if (rflags & cx.CXCF_FLAG_NOTFOUND) > 0:
        ret.append('Channel not found')

    if (rflags & cx.CXCF_FLAG_COLOR_WEIRD) > 0:
        ret.append('Value is weird')

    if (rflags & cx.CXCF_FLAG_ALARM_ALARM) > 0:
        ret.append('Alarm!')

    if (rflags & cx.CXCF_FLAG_ALARM_RELAX) > 0:
        ret.append('Relaxing after alarm')

    if (rflags & cx.CXCF_FLAG_COLOR_RED) > 0:
        ret.append('Value in red zone')

    if (rflags & cx.CXCF_FLAG_COLOR_YELLOW) > 0:
        ret.append('Value in yellow zone')

    return ret