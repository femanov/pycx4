from cda cimport *
from libc.stdlib cimport realloc, free
from libc.string cimport memmove

IF SIGNAL_IMPL=='cda_signal':
    include 'cda_signal.pxi'
ELIF SIGNAL_IMPL=='pyqtSignal':
    include 'qt_signalers.pxi'

PY_CXDTYPE_UNKNOWN = CXDTYPE_UNKNOWN
PY_CXDTYPE_INT8 = CXDTYPE_INT8
PY_CXDTYPE_INT16 = CXDTYPE_INT16
PY_CXDTYPE_INT32 = CXDTYPE_INT32
PY_CXDTYPE_INT64 = CXDTYPE_INT64
PY_CXDTYPE_UINT8 = CXDTYPE_UINT8
PY_CXDTYPE_UINT16 = CXDTYPE_UINT16
PY_CXDTYPE_UINT32 = CXDTYPE_UINT32
PY_CXDTYPE_UINT64 = CXDTYPE_UINT64
PY_CXDTYPE_SINGLE = CXDTYPE_SINGLE
PY_CXDTYPE_DOUBLE = CXDTYPE_DOUBLE
PY_CXDTYPE_TEXT = CXDTYPE_TEXT
PY_CXDTYPE_UCTEXT = CXDTYPE_UCTEXT

# struct to extend private pointer
ctypedef struct event:
    int evmask    # cda eventmask
    void *evproc  # pointer to proc function
    void *objptr  # pointer to sender object
    void *userptr # pointer to user data

# check for cda exception
cdef inline int cda_check_exception(int code) except -1:
    if code < 0:
        raise Exception("cda error: %s, errcode: %s" % (cda_last_err(), code))
    return 0

# C callback for context
cdef void evproc_cont_cycle(int uniq, void *privptr1, cda_context_t cid, int reason,
                      int info_int, void *privptr2) with gil:
    cdef cda_context cont=<cda_context>(<event*>privptr2).objptr
    cont.serverCycle.emit(cont)

# C callback function for ref's (channels)
cdef void evproc_rslvstat(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                          void *info_ptr, void *privptr2) with gil:
    #cdef cda_base_chan chan = (<event*>privptr2).objptr # segmentation fault - not yet get why
    if <long>info_ptr == 0: # this is channel not found
        #(.found=-1
        pass

cdef void evproc_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        cx_time_t timestr
        rflags_t rflags
        cda_base_chan chan = <cda_base_chan>(<event*>privptr2).objptr
    cda_check_exception( cda_get_ref_stat(chan.ref, &rflags, &timestr) )
    chan.prev_time = chan.time
    chan.time = <int64>timestr.sec * 1000000 + timestr.nsec / 1000
    chan.cb()


# event handling functions
cdef inline int event_feasible(event *ev):
    if ev.evmask == 0 or ev.evproc == NULL or ev.objptr == NULL:
        return 0
    return 1

cdef inline int cmp_events(event *ev1, event *ev2):
    if ev1.evmask == ev2.evmask and ev1.evproc == ev2.evproc and \
        ev1.objptr == ev2.objptr and ev1.userptr == ev2.userptr:
        return 0
    return 1

# classes

cdef class cda_object:
    cdef:
        event *events
        int evnum

    def __cinit__(self):
        self.events = NULL
        self.evnum = 0

    def __dealloc__(self):
        free(self.events)

    cdef int add_event(self,int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            event ev
            void *tmp
        ev.evmask, ev.evproc, ev.objptr, ev.userptr = evmask, evproc, objptr, userptr

        if event_feasible(&ev) == 0 or self.search_event(&ev) > -1:
            # event will not run or already exist
            return 0
        tmp = realloc(self.events, sizeof(event) * (self.evnum + 1) )
        if not tmp: raise MemoryError()
        self.events = <event*>tmp
        self.events[self.evnum] = ev
        self.register_event(&self.events[self.evnum])
        self.evnum += 1
        return 1

    cdef int del_event(self, int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            event ev
            int ev_ind

        ev.evmask, ev.evproc, ev.objptr, ev.userptr = evmask, evproc, objptr, userptr
        ev_ind = self.search_event(&ev)
        if ev_ind < 0: # event does not exist
            return 0
        self.unregister_event(&(self.events[ev_ind]))
        if self.evnum == 1:
            free(self.events)
        else:
            memmove(&(self.events[ev_ind]), &(self.events[self.evnum-1]), sizeof(event))
            tmp = realloc(self.events, sizeof(event) * (self.evnum - 1))
            if not tmp: raise MemoryError()
            self.events = <event*>tmp
        self.evnum -= 1
        return 1

    cdef int search_event(self, event *ev):
        for ind in range(self.evnum):
            if cmp_events(&self.events[ind], ev) == 0:
                return ind
        return -1

    cdef void register_event(self, event *ev):
        return

    cdef void unregister_event(self, event *ev):
        return


cdef class cda_context(cda_object):
    cdef readonly:
        cda_context_t cid
        str defpfx

    cdef:
        void **chans
        int channum
    IF SIGNAL_IMPL=='cda_signal':
        cdef readonly:
            cda_signal serverCycle
    ELIF SIGNAL_IMPL=='pyqtSignal':
        cdef:
            object signaler
            public object serverCycle

    def __cinit__(self, defpfx="cx::"):
        cdef:
            int ret
            char *c_defpfx
        ascii_pfx = defpfx.encode("ascii") # encode to ascii
        c_defpfx = ascii_pfx  # convert to char*

        ret = cda_new_context(0, NULL, c_defpfx, 0, NULL, 0, <cda_context_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.cid, self.defpfx, self.chans, self.channum = ret, defpfx, NULL, 0

        IF SIGNAL_IMPL=='cda_signal':
            self.serverCycle = cda_signal()
        ELIF SIGNAL_IMPL=='pyqtSignal':
            self.signaler = ContSignaler()
            self.serverCycle = self.signaler.serverCycle

    def __dealloc__(self):
        if self.cid > 0:
            cda_check_exception( cda_del_context(self.cid) )
            self.cid = 0
        free(self.chans)
        self.channum = 0

    def __str__(self):
        return '<cda_context: cid=%d, defpfx=%s, channum=%d>' % (self.cid, self.defpfx, self.channum)

    def enable_serverCycle(self):
        self.add_event(CDA_CTX_EVMASK_CYCLE, <void*>evproc_cont_cycle, <void*>self, NULL)

    cdef void save_chan(self, void *chan):
        cdef:
            void *tmp = realloc(<void*>self.chans, sizeof(void*) * (self.channum+1))
        if not tmp: raise MemoryError()
        self.chans = <void**>tmp
        self.chans[self.channum] = chan
        self.channum += 1

    cdef void drop_chan(self, void *chan):
        if not self.cid: return
        cdef:
            void *tmp
            int ind
        for ind in range(self.channum):
            if chan == self.chans[ind]:
                if self.channum == 1:
                    free(self.chans)
                else:
                    memmove(&(self.chans[ind]), &(self.chans[self.channum-1]), sizeof(void*) )
                    tmp = realloc(<void*>self.chans, sizeof(void*) * (self.channum-1))
                    if not tmp and self.channum>1: raise MemoryError()
                    self.chans = <void**>tmp
                self.channum -= 1
                return

    cdef void register_event(self, event *ev):
        cda_check_exception( cda_add_context_evproc(self.cid, ev.evmask, <cda_context_evproc_t>ev.evproc, ev) )

    cdef void unregister_event(self, event *ev):
        cda_check_exception( cda_del_context_evproc(self.cid, ev.evmask, <cda_context_evproc_t>ev.evproc, ev) )


cdef cda_context default_context=cda_context()

# wrapper-class for low-level functions and channel registration
cdef class cda_base_chan(cda_object):
    cdef readonly:
        cda_dataref_t ref
        str name
        int max_nelems
        cxdtype_t dtype
        size_t itemsize
        int64 time, prev_time
        int found # -1 - not found, 0 - unknown, 1 found

    cdef:
        int first_cycle
        void *context
        int registered

    IF SIGNAL_IMPL=='cda_signal':
        cdef readonly:
            cda_signal valueMeasured
            cda_signal valueChanged
    ELIF SIGNAL_IMPL=='pyqtSignal':
        cdef:
            object signaler
            public object valueChanged
            public object valueMeasured

    def __cinit__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1):
        if not isinstance(context, cda_context):
            self.context = <void*>default_context
        else:
            self.context = <void*>context

        IF SIGNAL_IMPL=='cda_signal':
            self.valueMeasured = cda_signal()
            self.valueChanged = cda_signal()
        ELIF SIGNAL_IMPL=='pyqtSignal':
            self.signaler = ChanSignaler()
            self.valueChanged = self.signaler.valueChanged
            self.valueMeasured = self.signaler.valueMeasured

        b_name = name.encode("ascii")
        cdef:
            char *c_name = b_name
            int ret

        ret = cda_add_chan((<cda_context>self.context).cid, NULL, c_name, 0, dtype, max_nelems,
                                0, <cda_dataref_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.ref, self.name, self.dtype, self.max_nelems, self.first_cycle, self.itemsize =\
            ret, name, dtype, max_nelems, True, sizeof_cxdtype(dtype)

        (<cda_context>self.context).save_chan(<void*>self)

        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_UPDATE,   <void*>evproc_update,   <void*>self, NULL)
        self.registered = 1

    def __dealloc__(self):
        cda_del_chan(self.ref)
        if self.registered:
            (<cda_context>self.context).drop_chan(<void*>self)

    def __str__(self):
        return '<cda_channel: ref=%d, name=%s>' % (self.ref, self.name)

    cdef void cb(self):
        #empty callback for overrideing
        pass

    cdef void snd_data(self, cxdtype_t dtype, int nelems, void* data_p):
        cda_check_exception( cda_snd_ref_data(self.ref, dtype, nelems, data_p) )

    cdef void get_data(self, size_t ofs, size_t size, void* buf):
        cda_check_exception( cda_get_ref_data(self.ref, ofs, size, buf) )

    cdef int current_nelems(self):
        return cda_current_nelems_of_ref(self.ref)

    cdef void get_src(self, const char **src_p):
        cda_check_exception(cda_src_of_ref(self.ref, src_p))

    # overriding cda_object methods
    cdef void register_event(self, event *ev):
        cda_check_exception( cda_add_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )

    cdef void unregister_event(self, event *ev):
        cda_check_exception( cda_del_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )



