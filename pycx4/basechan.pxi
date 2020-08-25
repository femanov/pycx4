

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

cdef void range_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    chan.get_range()

cdef void strs_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    chan.get_strings()


cdef void lockstat_update(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                        void *info_ptr, void *privptr2) with gil:
    cdef:
        BaseChan chan = <BaseChan>(<event*>privptr2).objptr
    chan.get_lockstate()


# wrapper-class for low-level functions and channel registration
cdef class BaseChan(CdaObject):
    cdef readonly:
        cda_dataref_t ref      # chan id
        str name               # chan name
        int max_nelems         # max number of elements when registered
        cxdtype_t dtype        # data type
        size_t itemsize        # item size in bytes
        int64 time, prev_time  # last and prev data update time
        long rslv_stat         # resolving status
        str rslv_str           # resolving string
        double quant
        int registered, first_cycle
        Context context
        rflags_t rflags        # flags
        list rng               # ranges
        # strings of ref
        char *ident
        char *label
        char *tip
        char *comment
        char *geoinfo
        char *rsrvd6
        char *units
        char *dpyfmt
    cdef public:
        object valueMeasured, valueChanged, resolve

    def __init__(self, str name, **kwargs):
        CdaObject.__init__(self)
        self.context = kwargs.get('context', default_context)
        self.max_nelems = kwargs.get('max_nelems', 1)
        dtype = kwargs.get('dtype', CXDTYPE_DOUBLE)
        if type(dtype) == str:
            self.dtype = cx_dtype_map[dtype]
        else:
            self.dtype = dtype

        self.valueChanged, self.valueMeasured, self.resolve = Signal(object), Signal(object), Signal(object)

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
        self.ref, self.name, self.itemsize = ret, name, sizeof_cxdtype(dtype)

        (<Context>self.context).save_chan(<void*>self)

        # events which can be regular
        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update, <void*>self, NULL)

        self.add_event(CDA_REF_EVMASK_QUANTCHG, <void*>quant_update, <void*>self, NULL)
        self.add_event(CDA_REF_EVMASK_RANGECHG, <void*>range_update, <void*>self, NULL)

        self.add_event(CDA_REF_EVMASK_STRSCHG, <void*>strs_update, <void*>self, NULL)

        self.add_event(CDA_REF_EVMASK_LOCKSTAT, <void*>lockstat_update, <void*>self, NULL)

        # TODO: need to allow user to select registered events

        ## <-- have some implementation
        ## CDA_REF_EVMASK_UPDATE
        # CDA_REF_EVMASK_STATCHG
        # CDA_REF_EVMASK_STRSCHG
        # CDA_REF_EVMASK_RDSCHG
        # CDA_REF_EVMASK_FRESHCHG
        ## CDA_REF_EVMASK_QUANTCHG
        ## CDA_REF_EVMASK_RANGECHG
        ## CDA_REF_EVMASK_RSLVSTAT
        # CDA_REF_EVMASK_CURVAL
        # CDA_REF_EVMASK_LOCKSTAT

        # initialization events (will be unregistered when get)

        self.registered, self.first_cycle = True, True
        self.rslv_stat = CDA_RSLVSTAT_SEARCHING
        self.rslv_str = 'searching'
        self.rng = []

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

    cpdef rflags_text(self):
        return rflags_text(self.rflags)

    # TESTING functions, not yet fully implemented
    cpdef get_range(self):
        cdef CxAnyVal_t r[2]
        cdef cxdtype_t dt
        c_res = cda_range_of_ref(self.ref, r, &dt)
        if dt == CXDTYPE_UNKNOWN:
            self.rng = []
        else:
            self.rng = [aval_value(&(r[0]), dt), aval_value(&(r[1]), dt)]

    cpdef get_strings(self):
        c_res = cda_strings_of_ref(self.ref, &self.ident, &self.label, &self.tip, &self.comment,
                                   &self.geoinfo, &self.rsrvd6, &self.units, &self.dpyfmt)
        print("string update")
        if self.ident != NULL: print("ident=", self.ident)
        if self.label != NULL: print("label=", self.label)
        if self.tip != NULL: print("tip=", self.tip)
        if self.comment != NULL: print("comment=", self.comment)
        if self.geoinfo != NULL: print("geoinfo=", self.geoinfo)
        if self.rsrvd6 != NULL: print("rsrvd6=", self.rsrvd6)
        if self.units != NULL: print("units=", self.units)
        if self.dpyfmt != NULL: print("dpyfmt=", self.dpyfmt)

    cpdef get_lockstate(self):
        print("updating lock state")
        pass

    cpdef lock(self):
        pass
        #res = cda_lock_chans(1, &(self.ref), CX_LOCK_WRITE_SET)
