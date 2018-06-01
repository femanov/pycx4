
# C callback for context
cdef void evproc_cont_cycle(int uniq, void *privptr1, cda_context_t cid, int reason,
                      int info_int, void *privptr2) with gil:
    cdef Context cont=<Context>(<event*>privptr2).objptr
    cont.serverCycle.emit(cont)


cdef class Context(CdaObject):
    cdef readonly:
        cda_context_t cid
        str defpfx

    cdef:
        void **chans
        int channum
    IF SIGNAL_IMPL=='sl':
        cdef readonly:
            Signal serverCycle
    ELIF SIGNAL_IMPL=='Qt':
        cdef:
            object c_serverCycle
            public object serverCycle

    def __init__(self, defpfx="cx::", **kwargs):
        super(Context, self).__init__()
        cdef:
            int ret
            int options = 0
            char *c_defpfx
        ascii_pfx = defpfx.encode("ascii") # encode to ascii
        c_defpfx = ascii_pfx  # convert to char*


        if 'other_opp_flag' in kwargs:
            if kwargs['other_opp_flag']:
                options += CDA_CONTEXT_OPT_NO_OTHEROP

        if 'ignore_update' in kwargs:
            if kwargs['ignore_update']:
                options += CDA_CONTEXT_OPT_IGN_UPDATE

        ret = cda_new_context(0, NULL, c_defpfx, options, NULL, 0, <cda_context_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.cid, self.defpfx, self.chans, self.channum = ret, defpfx, NULL, 0

        IF SIGNAL_IMPL=='sl':
            self.serverCycle = Signal()
        ELIF SIGNAL_IMPL=='Qt':
            self.c_serverCycle = SignalContainer()
            self.serverCycle = self.c_serverCycle.signal

    def __dealloc__(self):
        if self.cid > 0:
            cda_check_exception( cda_del_context(self.cid) )
            self.cid = 0
        if self.channum > 0:
            free(self.chans)
            self.chans = NULL
            self.channum = 0

    def __str__(self):
        return '<CdaContext: cid=%d, defpfx=%s, channum=%d>' % (self.cid, self.defpfx, self.channum)

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
                    self.chans = NULL
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
