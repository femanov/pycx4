from cx4.cxscheduler cimport sl_add_fd, sl_del_fd, sl_fdh_t, sl_set_fd_mask

cdef void fd_event_proc(int uniq, void *privptr1, sl_fdh_t fdh, int fd, int mask, void *privptr2) with gil:
    cdef FdEvent fev = <FdEvent>privptr1
    fev.ready.emit(fev)


cdef class FdEvent:
    """
    File descriptor event class
    --------
    file - something with .fileno()
    mask - event mask (summable)
    ready - signal, emmited when event happens
    set_mask(mask) - update mask run-time
    --------
    mask constants:
    SL_RD - Watch when descriptor is ready for read
    SL_WR - Watch when descriptor is ready for write
    SL_EX - Watch descriptor for exceptions (in fact -- OOB data)
    SL_CE - Watch for Connect Errors. That's a hint for Xh_cxscheduler exclusively

    """
    cdef readonly:
        object file, ready
        int mask
        sl_fdh_t fhd # event id

    def __cinit__(self, file, int mask=SL_RD):
        self.file = file
        self.mask = mask
        self.ready = InstSignal(object)
        self.fhd = sl_add_fd(0, <void*>self, file.fileno(), mask, fd_event_proc, NULL)

    def __dealloc__(self):
        sl_del_fd(self.fhd)

    def set_mask(self, int mask):
        sl_set_fd_mask(self.fdh, mask)
        self.mask = mask
        # 2DO: need to think about exception-checking code here

