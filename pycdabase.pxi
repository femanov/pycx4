from cda cimport *
from libc.stdlib cimport realloc, free
from libc.string cimport memmove

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
cdef void evproc_cont(int uniq, void *privptr1, cda_context_t cid, int reason,
                      int info_int, void *privptr2):
    pass

# C callback function for ref's (channels)
cdef void evproc_rslvstat(int uniq, void *privptr1, cda_dataref_t ref, int reason,
                          void *info_ptr, void *privptr2) with gil:
    chan = <cda_base_chan>(<event*>privptr2)[0].objptr
    if <long>info_ptr == 0: # this is channel not found
        chan.notFound = -1
        print("Error: channel not found %s.%s" % (chan.base, chan.spec))

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

    def __cinit__(self, defpfx="cx::"):
        cdef:
            int ret
            char *c_defpfx
        ascii_pfx = defpfx.encode("ascii") # encode to ascii
        c_defpfx = ascii_pfx  # convert to char*

        ret = cda_new_context(0, NULL, c_defpfx, 0, NULL, 0, <cda_context_evproc_t>NULL, NULL)
        cda_check_exception(ret)
        self.cid, self.defpfx, self.chans, self.channum = ret, defpfx, NULL, 0

    def __dealloc__(self):
        cda_check_exception( cda_del_context(self.cid) )
        self.cid = 0
        free(self.chans)
        self.channum = 0

    def __str__(self):
        return '<cda_context: cid=%d, defpfx=%s>' % (self.cid, self.defpfx)

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


default_context = cda_context()

# classes for channels

# wrapper-class for low-level functions and channel registration
cdef class cda_base_chan(cda_object):
    cdef readonly:
        int max_nelems
        cda_dataref_t ref
        cxdtype_t dtype
        str name
        int64 time, prev_time
        size_t itemsize

    cdef:
        int notFound # 0 - unknown, 1 found, -1 not found
        int first_cycle
        void *context

    def __cinit__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1):
        if not isinstance(context, cda_context):
            self.context = <void*>default_context
        else:
            self.context = <void*>context

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
        # registering callback to check if channel found
        self.add_event(CDA_REF_EVMASK_RSLVSTAT, <void*>evproc_rslvstat, <void*>self, NULL)
        # registering data update callback
        self.add_event(CDA_REF_EVMASK_UPDATE, <void*>evproc_update, <void*>self, NULL)
        # evproc_update just run self.base_cb, then self.cb
        # base_cb - common work
        # cb - type-special work

    def __dealloc__(self):
        cda_del_chan(self.ref)
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

    # overriding cda_object method
    cdef void register_event(self, event *ev):
        cda_check_exception( cda_add_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )

    cdef void unregister_event(self, event *ev):
        cda_check_exception( cda_del_dataref_evproc(self.ref, ev.evmask, <cda_dataref_evproc_t>ev.evproc, ev) )


