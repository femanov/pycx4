from cx4.cxscheduler cimport sl_tout_proc, sl_enq_tout_after, sl_tid_t, sl_deq_tout

cdef void sltimer_proc(int uniq, void *privptr1, sl_tid_t tid, void *privptr2) with gil:
    cdef Timer t = <Timer>privptr2
    if t.repeat:
        t.tid = sl_enq_tout_after(0, NULL, t.usecs, sltimer_proc, privptr2)
    else:
        t.active = 0
    t.timeout.emit(t)



cdef class Timer:
    cdef readonly:
        int usec
        int repeat
        int active
        sl_tid_t tid
        Signal timeout

    def __init__(self, int msec=1000):
        self.setInterval(msec)
        self.repeat = 1
        self.timeout = Signal()

    cpdef stop(self):
        if self.active == 1:
            self.active = 0
            sl_deq_tout(self.tid)

    cpdef start(self):
        if self.\
                active == 1:
            return
        self.active = 1
        self.tid = sl_enq_tout_after(0, NULL, self.usecs, sltimer_proc, <void*>self)

    cpdef singleShot(self, int msec=0, proc=None):
        if msec > 0:
            self.setInterval(msec)
        if proc is not None:
            self.timeout.connect(proc)
        self.repeat = 0
        self.start()

    cpdef int interval(self):
        return <int>(self.usec/1000)

    cpdef void setInterval(self, int msec):
        self.usec = 1000 * msec





