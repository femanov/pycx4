
cpdef set rflags_text(rflags_t rflags):
    ret = set()
    if (rflags & CXRF_CAMAC_NO_X) > 0:
        ret.add('No X from CAMAC device')
    if (rflags & CXRF_CAMAC_NO_Q) > 0:
        ret.add('No Q from CAMAC device')
    if (rflags & CXRF_IO_TIMEOUT) > 0:
        ret.add('I/O timeout expired')
    if (rflags & CXRF_REM_C_PROBL) > 0:
        ret.add('Remote controller problem')
    if (rflags & CXRF_OVERLOAD) > 0:
        ret.add('Input channel overload')
    if (rflags & CXRF_UNSUPPORTED) > 0:
        ret.add('Unsupported feature/channel')
    if (rflags & CXRF_INVAL) > 0:
        ret.add('Invalid parameter')
    if (rflags & CXRF_WRONG_DEV) > 0:
        ret.add('Wrong device')
    if (rflags & CXRF_CFG_PROBL) > 0:
        ret.add('Configuration problem')
    if (rflags & CXRF_DRV_PROBL) > 0:
        ret.add('Driver internal problem')
    if (rflags & CXRF_NO_DRV) > 0:
        ret.add('Driver loading problem')
    if (rflags & CXRF_OFFLINE) > 0:
        ret.add('Device is offline')
    if (rflags & CXCF_FLAG_CALCERR) > 0:
        ret.add('Formula calculation error')
    if (rflags & CXCF_FLAG_DEFUNCT) > 0:
        ret.add('Defunct channel')
    if (rflags & CXCF_FLAG_OTHEROP) > 0:
        ret.add('Other operator is active')
    if (rflags & CXCF_FLAG_PRGLYCHG) > 0:
        ret.add('Channel was programmatically changed')
    if (rflags & CXCF_FLAG_NOTFOUND) > 0:
        ret.add('Channel not found')
    if (rflags & CXCF_FLAG_COLOR_WEIRD) > 0:
        ret.add('Value is weird')
    if (rflags & CXCF_FLAG_ALARM_ALARM) > 0:
        ret.add('Alarm!')
    if (rflags & CXCF_FLAG_ALARM_RELAX) > 0:
        ret.add('Relaxing after alarm')
    if (rflags & CXCF_FLAG_COLOR_RED) > 0:
        ret.add('Value in red zone')
    if (rflags & CXCF_FLAG_COLOR_YELLOW) > 0:
        ret.add('Value in yellow zone')
    return ret


cpdef tuple rflags_color_status(rflags_t rflags):
    if rflags == 0:
        return None, 'normal'
    elif (rflags & CXRF_CAMAC_NO_X) > 0 or\
         (rflags & CXRF_CAMAC_NO_Q) > 0 or\
         (rflags & CXRF_IO_TIMEOUT) > 0 or \
         (rflags & CXRF_REM_C_PROBL) > 0 or \
         (rflags & CXRF_OVERLOAD) > 0 or \
         (rflags & CXRF_UNSUPPORTED) > 0:
        return '#B03060', 'hwerr'
    elif (rflags & CXRF_INVAL) > 0 or\
         (rflags & CXRF_WRONG_DEV) > 0 or\
         (rflags & CXRF_CFG_PROBL) > 0 or\
         (rflags & CXRF_DRV_PROBL) > 0 or\
         (rflags & CXRF_NO_DRV) > 0 or \
         (rflags & CXRF_OFFLINE) > 0 or \
         (rflags & CXCF_FLAG_CALCERR) > 0:
        return '#8B8B00', 'sferr'
    elif (rflags & CXCF_FLAG_DEFUNCT) > 0:
        return '#4682B4', 'defunct'
    elif (rflags & CXCF_FLAG_OTHEROP) > 0:
        return '#FFA500', 'otherop'
    elif (rflags & CXCF_FLAG_PRGLYCHG) > 0:
        return '#D8E3D5', 'prglychg'
    elif (rflags & CXCF_FLAG_NOTFOUND) > 0:
        return '#404040', 'notfound'
    elif (rflags & CXCF_FLAG_COLOR_WEIRD) > 0:
        return '#0000FF', 'weird'
    elif (rflags & CXCF_FLAG_COLOR_YELLOW) > 0:
        return '#EDED6D', 'yellow'
    elif (rflags & CXCF_FLAG_COLOR_RED) > 0:
        return '#FFC0CB', 'red'
    elif (rflags & CXCF_FLAG_ALARM_ALARM) > 0:
        return '#FFC0CB', 'alarm'
    elif (rflags & CXCF_FLAG_ALARM_RELAX) > 0:
        return '#00FF00', 'alarm_relaxed'


rflags_order = [CXRF_CAMAC_NO_X,
               CXRF_CAMAC_NO_Q,
               CXRF_IO_TIMEOUT,
               CXRF_REM_C_PROBL,
               CXRF_OVERLOAD,
               CXRF_UNSUPPORTED,
               CXRF_INVAL,
               CXRF_WRONG_DEV,
               CXRF_CFG_PROBL,
               CXRF_DRV_PROBL,
               CXRF_NO_DRV,
               CXRF_OFFLINE,
               CXCF_FLAG_CALCERR,
               CXCF_FLAG_DEFUNCT,
               CXCF_FLAG_OTHEROP,
               CXCF_FLAG_PRGLYCHG,
               CXCF_FLAG_NOTFOUND,
               CXCF_FLAG_COLOR_WEIRD,
               CXCF_FLAG_ALARM_ALARM,
               CXCF_FLAG_ALARM_RELAX,
               CXCF_FLAG_COLOR_RED,
               CXCF_FLAG_COLOR_YELLOW
               ]

rflags_meaning = {
   CXRF_CAMAC_NO_X: 'No X from CAMAC device',
   CXRF_CAMAC_NO_Q: 'No Q from CAMAC device',
   CXRF_IO_TIMEOUT: 'I/O timeout expired',
   CXRF_REM_C_PROBL: 'Remote controller problem',
   CXRF_OVERLOAD: 'Input channel overload',
   CXRF_UNSUPPORTED: 'Unsupported feature/channel',
   CXRF_INVAL: 'Invalid parameter',
   CXRF_WRONG_DEV: 'Wrong device',
   CXRF_CFG_PROBL: 'Configuration problem',
   CXRF_DRV_PROBL: 'Driver internal problem',
   CXRF_NO_DRV: 'Driver loading problem',
   CXRF_OFFLINE: 'Device is offline',
   CXCF_FLAG_CALCERR: 'Formula calculation error',
   CXCF_FLAG_DEFUNCT: 'Defunct channel',
   CXCF_FLAG_OTHEROP: 'Other operator is active',
   CXCF_FLAG_PRGLYCHG: 'Channel was programmatically changed',
   CXCF_FLAG_NOTFOUND: 'Channel not found',
   CXCF_FLAG_COLOR_WEIRD: 'Value is weird',
   CXCF_FLAG_ALARM_ALARM: 'Alarm!',
   CXCF_FLAG_ALARM_RELAX: 'Relaxing after alarm',
   CXCF_FLAG_COLOR_RED: 'Value in red zone',
   CXCF_FLAG_COLOR_YELLOW: 'Value in yellow zone',
}

rflags_color = {
# 'hwerr'
CXRF_CAMAC_NO_X: '#B03060',
CXRF_IO_TIMEOUT: '#B03060',
CXRF_REM_C_PROBL: '#B03060',
CXRF_OVERLOAD: '#B03060',
CXRF_UNSUPPORTED: '#B03060',
# 'sferr'
CXRF_INVAL: '#8B8B00',
CXRF_WRONG_DEV: '#8B8B00',
CXRF_CFG_PROBL: '#8B8B00',
CXRF_DRV_PROBL: '#8B8B00',
CXRF_NO_DRV: '#8B8B00',
CXRF_OFFLINE: '#8B8B00',

CXCF_FLAG_CALCERR: '#8B8B00',
CXCF_FLAG_DEFUNCT: '#4682B4', # 'defunct'
CXCF_FLAG_OTHEROP: '#FFA500', # 'otherop'
CXCF_FLAG_PRGLYCHG: '#D8E3D5', # 'prglychg'
CXCF_FLAG_NOTFOUND: '#404040', # 'notfound'
CXCF_FLAG_COLOR_WEIRD: '#0000FF', # 'weird'
CXCF_FLAG_COLOR_YELLOW: '#EDED6D', # 'yellow'
CXCF_FLAG_COLOR_RED: '#FFC0CB', # 'red'
CXCF_FLAG_ALARM_ALARM: '#FFC0CB', # 'alarm'
CXCF_FLAG_ALARM_RELAX: '#00FF00', # 'alarm_relaxed'

}


cdef class CXRFlagsClass:
    cdef readonly:
        rflags_t CXRF_CAMAC_NO_X
        rflags_t CXRF_CAMAC_NO_Q
        rflags_t CXRF_IO_TIMEOUT
        rflags_t CXRF_REM_C_PROBL
        rflags_t CXRF_OVERLOAD
        rflags_t CXRF_UNSUPPORTED
        rflags_t CXRF_INVAL
        rflags_t CXRF_WRONG_DEV
        rflags_t CXRF_CFG_PROBL
        rflags_t CXRF_DRV_PROBL
        rflags_t CXRF_NO_DRV
        rflags_t CXRF_OFFLINE
        rflags_t CXCF_FLAG_CALCERR
        rflags_t CXCF_FLAG_DEFUNCT
        rflags_t CXCF_FLAG_OTHEROP
        rflags_t CXCF_FLAG_PRGLYCHG
        rflags_t CXCF_FLAG_NOTFOUND
        rflags_t CXCF_FLAG_COLOR_WEIRD
        rflags_t CXCF_FLAG_ALARM_ALARM
        rflags_t CXCF_FLAG_ALARM_RELAX
        rflags_t CXCF_FLAG_COLOR_RED
        rflags_t CXCF_FLAG_COLOR_YELLOW

    def __cinit__(self):
        self.CXRF_CAMAC_NO_X = CXRF_CAMAC_NO_X
        self.CXRF_CAMAC_NO_Q = CXRF_CAMAC_NO_Q
        self.CXRF_IO_TIMEOUT = CXRF_IO_TIMEOUT
        self.CXRF_REM_C_PROBL = CXRF_REM_C_PROBL
        self.CXRF_OVERLOAD = CXRF_OVERLOAD
        self.CXRF_UNSUPPORTED = CXRF_UNSUPPORTED
        self.CXRF_INVAL = CXRF_INVAL
        self.CXRF_WRONG_DEV = CXRF_WRONG_DEV
        self.CXRF_CFG_PROBL = CXRF_CFG_PROBL
        self.CXRF_DRV_PROBL = CXRF_DRV_PROBL
        self.CXRF_NO_DRV = CXRF_NO_DRV
        self.CXRF_OFFLINE = CXRF_OFFLINE
        self.CXCF_FLAG_CALCERR = CXCF_FLAG_CALCERR
        self.CXCF_FLAG_DEFUNCT = CXCF_FLAG_DEFUNCT
        self.CXCF_FLAG_OTHEROP = CXCF_FLAG_OTHEROP
        self.CXCF_FLAG_PRGLYCHG = CXCF_FLAG_PRGLYCHG
        self.CXCF_FLAG_NOTFOUND = CXCF_FLAG_NOTFOUND
        self.CXCF_FLAG_COLOR_WEIRD = CXCF_FLAG_COLOR_WEIRD
        self.CXCF_FLAG_ALARM_ALARM = CXCF_FLAG_ALARM_ALARM
        self.CXCF_FLAG_ALARM_RELAX = CXCF_FLAG_ALARM_RELAX
        self.CXCF_FLAG_COLOR_RED = CXCF_FLAG_COLOR_RED
        self.CXCF_FLAG_COLOR_YELLOW = CXCF_FLAG_COLOR_YELLOW

#serves to bring flags constants to Python if someone need it
CXRFlags = CXRFlagsClass()