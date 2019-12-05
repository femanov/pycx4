

# C callback function for ref's (channels)
cdef void evproc_rslvstat(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                          void *info_ptr, void *privptr2) with gil:
    cdef BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    chan.rslv_stat = <long>info_ptr # resolve status passed through this pointer

    if chan.rslv_stat == CDA_RSLVSTAT_NOTFOUND:
        chan.rslv_str = 'not found'
    elif chan.rslv_stat == CDA_RSLVSTAT_SEARCHING:
        chan.rslv_str = 'searching'
    elif chan.rslv_stat == CDA_RSLVSTAT_FOUND:
        chan.rslv_str = 'found'
    chan.resolve.emit(chan)


cdef void evproc_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        cx_time_t timestr
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    chan.check_exception( cda_get_ref_stat(ref, &chan.rflags, &timestr) )

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
        print(chan.name, chan.quant)


# wrapper-class for low-level functions and channel registration
cdef class BaseChan(CdaObject):
    cdef readonly:
        cda_dataref_t ref
        str name
        int max_nelems
        cxdtype_t dtype
        size_t itemsize
        int64 time, prev_time
        long rslv_stat
        str rslv_str
        double quant
        int registered, first_cycle
        Context context
        rflags_t rflags

    IF SIGNAL_IMPL=='sl':
        cdef readonly:
            Signal valueMeasured, valueChanged, resolve
    ELIF SIGNAL_IMPL=='Qt':
        cdef:
            object c_valueChanged, c_valueMeasured, c_resolve
            public object valueChanged, valueMeasured, resolve

    def __init__(self, str name, **kwargs):
        CdaObject.__init__(self)
        self.context = kwargs.get('context', default_context)
        self.max_nelems = kwargs.get('max_nelems', 1)
        dtype = kwargs.get('dtype', cx.CXDTYPE_DOUBLE)
        if type(dtype) == str:
            self.dtype = cx_dtype_map[dtype]
        else:
            self.dtype = dtype

        IF SIGNAL_IMPL=='sl':
            self.valueChanged, self.valueMeasured, self.resolve = Signal(), Signal(), Signal()
        ELIF SIGNAL_IMPL=='Qt':
            self.c_valueChanged, self.c_valueMeasured, self.c_resolve = SignalContainer(), SignalContainer(), SignalContainer()
            self.valueChanged, self.valueMeasured, self.resolve = self.c_valueChanged.signal, self.c_valueMeasured.signal, self.c_resolve.signal

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

        if kwargs.get('debug', False):
            options += CDA_DATAREF_OPT_DEBUG

        ret = cda_add_chan((<Context>self.context).cid, NULL, c_name, options, self.dtype, self.max_nelems,
                           0, <cda_dataref_evproc_t>NULL, NULL)
        self.check_exception(ret)
        self.ref, self.name, self.itemsize = ret, name, cx.sizeof_cxdtype(dtype)

        (<Context>self.context).save_chan(<void*>self)

        # events which can be regular
        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_QUANTCHG, <void*>quant_update, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update, <void*>self, NULL)

        # initialization events (will be unregistered when get)

        self.registered, self.first_cycle = True, True
        self.rslv_stat = CDA_RSLVSTAT_SEARCHING
        self.rslv_str = 'searching'

    def __dealloc__(self):
        if self.registered:
            (<Context>self.context).drop_chan(<void*>self)
            cda_del_chan(self.ref)
            self.registered = 0

    def __str__(self):
        return '<cda_chan: ref=%d, name=%s>' % (self.ref, self.name)

    def short_name(self):
        a = self.name.split('.')
        return a[len(a)-1].split('@')[0]

    cdef void cb(self):
        #empty callback for overrideing
        pass

    cdef int snd_data(self, cxdtype_t dtype, int nelems, void* data_p):
        cdef int res = cda_snd_ref_data(self.ref, dtype, nelems, data_p)
        self.check_exception(res)

    cdef int get_data(self, size_t ofs, size_t size, void* buf):
        cdef int res = cda_get_ref_data(self.ref, ofs, size, buf)
        self.check_exception(res)
        return res

    cdef int current_nelems(self):
        return cda_current_nelems_of_ref(self.ref)

    cdef void get_src(self, const char **src_p):
        self.check_exception( cda_src_of_ref(self.ref, src_p) )

    cdef void register_event(self, event *ev):
        self.check_exception( cda_add_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )

    cdef void unregister_event(self, event *ev):
        self.check_exception( cda_del_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )

    cdef void check_exception(self, int c_res):
        if c_res < 0:
            raise Exception("cda chan error: cname=%s, %s, errcode=%s" % (self.name, cda_last_err(), c_res ))

    cpdef is_available(self):
        if self.rslv_stat == CDA_RSLVSTAT_FOUND:
            return True
        return False

    cpdef rflags_strings(self):
        return rflags_text(self.rflags)

    # TESTING functions, not yet fully implemented
    cpdef get_range(self):
        cdef CxAnyVal_t r[2]
        cdef cxdtype_t dt
        c_res = cda_range_of_ref(self.ref, r, &dt)
        print(c_res, dt, aval_value(&(r[0]), dt), aval_value(&(r[1]), dt))
        print(CXDTYPE_UNKNOWN)

    cpdef get_strings(self):
        cdef char *ident = NULL
        cdef char *label = NULL
        cdef char *tip = NULL
        cdef char *comment = NULL
        cdef char *geoinfo = NULL
        cdef char *rsrvd6 = NULL
        cdef char *units = NULL
        cdef char *dpyfmt = NULL
        print("before get")
        c_res = cda_strings_of_ref(self.ref, &ident, &label, &tip, &comment, &geoinfo,
                                   &rsrvd6, &units, &dpyfmt)
        print("after get")
        if ident != NULL:
            print("ident")
        if label != NULL:
            print("label")
        if tip != NULL:
            print("tip")
        if comment != NULL:
            print("comment")
        if geoinfo != NULL:
            print("geoinfo")
        if rsrvd6 != NULL:
            print("rsrvd6")
        if units != NULL:
            print("units")
        if dpyfmt != NULL:
            print("dpyfmt")

        # print(<bytes>ident, <bytes>label, <bytes>tip, <bytes>comment,
        #       <bytes>geoinfo, <bytes>rsrvd6, <bytes>units, <bytes>dpyfmt)
        print("after print")
