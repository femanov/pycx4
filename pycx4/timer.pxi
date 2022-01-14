from cx4.cxscheduler cimport sl_tout_proc, sl_enq_tout_after, sl_tid_t, sl_deq_tout

cdef void sltimer_proc(int uniq, void *privptr1, sl_tid_t tid, void *privptr2) with gil:
    cdef Timer t = <Timer>privptr2
    if t.repeat:
        t.tid = sl_enq_tout_after(0, NULL, t.usec, sltimer_proc, privptr2)
    else:
        t.active = 0
    t.timeout.emit()


cdef class Timer:
    """
    Timer class provides high-level to user in CX scheduler environment
    """
    cdef readonly:
        int usec
        int repeat
        int active
        sl_tid_t tid
        Signal timeout

    def __cinit__(self, int msec=1000):
        self.usec = msec * 1000
        self.repeat = 0
        self.active = 0
        self.timeout = Signal(object)

    cpdef void stop(self):
        """Stop any timer action."""
        if self.active:
            self.active = 0
            self.repeat = 0
            sl_deq_tout(self.tid)

    cpdef void start(self):
        """start timer for periodic shots.
         If timer is active it will be sopped and restarted"""
        if self.active == 1:
            sl_deq_tout(self.tid)
        self.active = 1
        self.repeat = 1
        self.tid = sl_enq_tout_after(0, NULL, self.usec, sltimer_proc, <void*>self)

    cpdef singleShot(self, int msec=0, proc=None):
        if msec > 0:
            self.setInterval(msec)
        if self.active == 1:
            sl_deq_tout(self.tid)
            self.tid = sl_enq_tout_after(0, NULL, self.usec, sltimer_proc, <void*>self)
        if proc is not None:
            self.timeout.connect(proc)
        self.active = 1
        self.repeat = 0
        self.tid = sl_enq_tout_after(0, NULL, self.usec, sltimer_proc, <void*>self)

    cpdef int interval(self):
        return <int>(self.usec/1000)

    cpdef void setInterval(self, int msec):
        """Set interval and restart timer if it is not running"""
        self.usec = 1000 * msec
        if self.active == 1:
            sl_deq_tout(self.tid)
            self.tid = sl_enq_tout_after(0, NULL, self.usec, sltimer_proc, <void*>self)

