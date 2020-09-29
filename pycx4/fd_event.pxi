from cx4.cxscheduler cimport sl_add_fd, sl_del_fd, sl_fdh_t

cdef void fd_event_proc(int uniq, void *privptr1, sl_fdh_t fdh, int fd, int mask, void *privptr2) with gil:
    cdef FdEvent fev = <FdEvent>privptr1
    fev.ready.emit(fev)


cdef class FdEvent:
    cdef readonly:
        object file, ready
        int mask
        sl_fdh_t fhd

    def __cinit__(self, file, mask=SL_RD):
        self.file = file
        self.mask = mask
        self.ready = Signal(object)
        self.fhd = sl_add_fd(0, <void*>self, file.fileno(), mask, fd_event_proc, NULL)

    def __dealloc__(self):
        sl_del_fd(self.fhd)
