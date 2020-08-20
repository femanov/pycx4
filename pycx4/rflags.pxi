
cdef list rflags_text(rflags_t rflags):
    ret = []
    if (rflags & CXRF_CAMAC_NO_X) > 0:
        ret.append('No X from CAMAC device')

    if (rflags & CXRF_CAMAC_NO_Q) > 0:
        ret.append('No Q from CAMAC device')

    if (rflags & CXRF_IO_TIMEOUT) > 0:
        ret.append('I/O timeout expired')

    if (rflags & CXRF_REM_C_PROBL) > 0:
        ret.append('Remote controller problem')

    if (rflags & CXRF_OVERLOAD) > 0:
        ret.append('Input channel overload')

    if (rflags & CXRF_UNSUPPORTED) > 0:
        ret.append('Unsupported feature/channel')

    if (rflags & CXRF_INVAL) > 0:
        ret.append('Invalid parameter')

    if (rflags & CXRF_WRONG_DEV) > 0:
        ret.append('Wrong device')

    if (rflags & CXRF_CFG_PROBL) > 0:
        ret.append('Configuration problem')

    if (rflags & CXRF_DRV_PROBL) > 0:
        ret.append('Driver internal problem')

    if (rflags & CXRF_NO_DRV) > 0:
        ret.append('Driver loading problem')

    if (rflags & CXRF_OFFLINE) > 0:
        ret.append('Device is offline')

    if (rflags & CXCF_FLAG_CALCERR) > 0:
        ret.append('Formula calculation error')

    if (rflags & CXCF_FLAG_DEFUNCT) > 0:
        ret.append('Defunct channel')

    if (rflags & CXCF_FLAG_OTHEROP) > 0:
        ret.append('Other operator is active')

    if (rflags & CXCF_FLAG_PRGLYCHG) > 0:
        ret.append('Channel was programmatically changed')

    if (rflags & CXCF_FLAG_NOTFOUND) > 0:
        ret.append('Channel not found')

    if (rflags & CXCF_FLAG_COLOR_WEIRD) > 0:
        ret.append('Value is weird')

    if (rflags & CXCF_FLAG_ALARM_ALARM) > 0:
        ret.append('Alarm!')

    if (rflags & CXCF_FLAG_ALARM_RELAX) > 0:
        ret.append('Relaxing after alarm')

    if (rflags & CXCF_FLAG_COLOR_RED) > 0:
        ret.append('Value in red zone')

    if (rflags & CXCF_FLAG_COLOR_YELLOW) > 0:
        ret.append('Value in yellow zone')

    return ret