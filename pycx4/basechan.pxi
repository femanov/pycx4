
# check for cda exception
# this is not correct. Exception can be raised on python's side, not in C
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
        print('channel name not resolved by server: %s' % chan.name)

cdef void evproc_update_init(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                          void *info_ptr, void *privptr2) with gil:
    cdef BaseChan chan = <BaseChan>(<event*>privptr2).objptr

    chan.initialized = 1
    chan.del_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update_init, <void*>chan, NULL)


cdef void evproc_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        cx_time_t timestr
        rflags_t rflags
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    cda_check_exception( cda_get_ref_stat(ref, &rflags, &timestr) )

    chan.prev_time = chan.time
    chan.time = <int64>timestr.sec * 1000000 + timestr.nsec / 1000
    chan.cb()


cdef void quant_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        int res
        CxAnyVal_t quant_raw
        cxdtype_t quant_dtype
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
        double quant_draw, val, shift

    res = cda_quant_of_ref(chan.ref, &quant_raw, &quant_dtype)
    quant_draw = aval_value(&quant_raw, quant_dtype)
    if quant_draw == 0:
        chan.quant = 0
        return
    else:
        res = cda_rd_convert(ref, 0, &shift)
        res = cda_rd_convert(ref, quant_draw, &val)
        chan.quant = val - shift


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
        double quant

    cdef:
        int registered, first_cycle, initialized
        void *context

    IF SIGNAL_IMPL=='sl':
        cdef readonly:
            Signal valueMeasured, valueChanged, unresolved
    ELIF SIGNAL_IMPL=='Qt':
        cdef:
            object c_valueChanged, c_valueMeasured, c_unresolved
            public object valueChanged, valueMeasured, unresolved

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1, **kwargs):
        CdaObject.__init__(self)
        if isinstance(context, Context): self.context = <void*>context
        else: self.context = <void*>default_context

        IF SIGNAL_IMPL=='sl':
            self.valueChanged, self.valueMeasured, self.unresolved = Signal(), Signal(), Signal()
        ELIF SIGNAL_IMPL=='Qt':
            self.c_valueChanged, self.c_valueMeasured, self.c_unresolved = SignalContainer(), SignalContainer(), SignalContainer()
            self.valueChanged, self.valueMeasured, self.unresolved = self.c_valueChanged.signal, self.c_valueMeasured.signal, self.c_unresolved.signal

        b_name = name.encode("ascii")
        cdef:
            char *c_name = b_name
            int ret
            unsigned int options = 0

        # may be cycle?
        if kwargs.get('private', False):
            options += CDA_DATAREF_OPT_PRIVATE

        if kwargs.get('no_rd_conv', False):
            options += CDA_DATAREF_OPT_NO_RD_CONV

        if kwargs.get('shy', False):
            options += CDA_DATAREF_OPT_SHY

        if kwargs.get('find_only', False):
            options += CDA_DATAREF_OPT_FIND_ONLY

        if kwargs.get('on_update', False):
            options += CDA_DATAREF_OPT_ON_UPDATE

        if kwargs.get('no_wr_wait', False):
            options += CDA_DATAREF_OPT_NO_WR_WAIT

        ret = cda_add_chan((<Context>self.context).cid, NULL, c_name, options, dtype, max_nelems,
                           0, <cda_dataref_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.ref, self.name, self.dtype, self.max_nelems, self.itemsize =\
            ret, name, dtype, max_nelems, cx.sizeof_cxdtype(dtype)

        (<Context>self.context).save_chan(<void*>self)

        # events which can be regular
        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_QUANTCHG, <void*>quant_update, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update, <void*>self, NULL)

        # initialization events (will be unregistered when get)

        # this one makes "initialized" flag
        # need to rewrite with function pointers replace
        self.add_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update_init, <void*>self, NULL)

        self.registered, self.first_cycle, self.initialized = 1, 1, 0

    def __dealloc__(self):
        if self.registered:
            (<Context>self.context).drop_chan(<void*>self)
            cda_del_chan(self.ref)
            self.registered = 0

    def __str__(self):
        return '<cda_channel: ref=%d, name=%s>' % (self.ref, self.name)

    def short_name(self):
        a = self.name.split('.')
        return a[len(a)-1].split('@')[0]

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



