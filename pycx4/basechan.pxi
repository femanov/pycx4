from cx4.cda cimport *

from cx4.cx cimport sizeof_cxdtype, cxdtype_t, cx_time_t, rflags_t

# check for cda exception
cdef inline int cda_check_exception(int code) except -1:
    if code < 0:
        raise Exception("cda error: %s, errcode: %s" % (cda_last_err(), code))
    return 0


# C callback function for ref's (channels)
cdef void evproc_rslvstat(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                          void *info_ptr, void *privptr2) with gil:
    cdef BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    if <long>info_ptr == 0: # this is channel not found event
        chan.found=-1
        print('channel name not resolved by server: %s' % (chan.name,))

cdef void evproc_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        cx_time_t timestr
        rflags_t rflags
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    cda_check_exception( cda_get_ref_stat(chan.ref, &rflags, &timestr) )
    chan.prev_time = chan.time
    chan.time = <int64>timestr.sec * 1000000 + timestr.nsec / 1000
    chan.cb()


# wrapper-class for low-level functions and channel registration
cdef class BaseChan(CdaObject):
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

    IF SIGNAL_IMPL=='sl':
        cdef readonly:
            Signal valueMeasured
            Signal valueChanged
    ELIF SIGNAL_IMPL=='Qt':
        cdef:
            object signaler
            public object valueChanged
            public object valueMeasured

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1):
        CdaObject.__init__(self)
        if isinstance(context, Context): self.context = <void*>context
        else: self.context = <void*>default_context

        IF SIGNAL_IMPL=='sl':
            self.valueMeasured = Signal()
            self.valueChanged = Signal()
        ELIF SIGNAL_IMPL=='Qt':
            self.signaler = ChanSignaler()
            self.valueChanged = self.signaler.valueChanged
            self.valueMeasured = self.signaler.valueMeasured

        b_name = name.encode("ascii")
        cdef:
            char *c_name = b_name
            int ret

        ret = cda_add_chan((<Context>self.context).cid, NULL, c_name, 0, dtype, max_nelems,
                           0, <cda_dataref_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.ref, self.name, self.dtype, self.max_nelems, self.first_cycle, self.itemsize =\
            ret, name, dtype, max_nelems, True, sizeof_cxdtype(dtype)

        (<Context>self.context).save_chan(<void*>self)

        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_UPDATE,   <void*>evproc_update,   <void*>self, NULL)
        self.registered = 1

    def __dealloc__(self):
        cda_del_chan(self.ref)
        if self.registered:
            (<Context>self.context).drop_chan(<void*>self)

    def __str__(self):
        return '<cda_channel: ref=%d, name=%s>' % (self.ref, self.name)

    cdef void cb(self):
        #empty callback for overrideing
        pass

    cdef int snd_data(self, cxdtype_t dtype, int nelems, void* data_p):
        cdef int res = cda_snd_ref_data(self.ref, dtype, nelems, data_p)
        cda_check_exception(res)
        return res

    cdef int get_data(self, size_t ofs, size_t size, void* buf):
        cdef int res = cda_get_ref_data(self.ref, ofs, size, buf)
        cda_check_exception(res)
        return res

    cdef int current_nelems(self):
        return cda_current_nelems_of_ref(self.ref)

    cdef void get_src(self, const char **src_p):
        cda_check_exception( cda_src_of_ref(self.ref, src_p) )

    cdef void register_event(self, event *ev):
        cda_check_exception( cda_add_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )

    cdef void unregister_event(self, event *ev):
        cda_check_exception( cda_del_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )



