from cx4.cxscheduler cimport sl_tout_proc, sl_enq_tout_after, sl_tid_t, sl_deq_tout

cdef void sltimer_proc(int uniq, void *privptr1, sl_tid_t tid, void *privptr2) with gil:
    cdef Timer t = <Timer>privptr2
    if t.repeat:
        t.tid = sl_enq_tout_after(0, NULL, t.usecs, sltimer_proc, privptr2)
    else:
        t.running = 0
    t.shot.emit(t)


cdef class Timer:
    cdef readonly:
        int usecs
        int repeat
        int running
        Signal shot
        sl_tid_t tid

    def __init__(self, int usecs, int repeat=0):
        self.usecs, self.repeat, self.running = usecs, repeat, 1
        tid = sl_enq_tout_after(0, NULL, usecs, sltimer_proc, <void*>self)
        self.shot = Signal()

    cpdef stop(self):
        if self.running:
            self.running = 0
            sl_deq_tout(self.tid)

    cpdef run(self):
        if not self.running:
            self.running = 0
            tid = sl_enq_tout_after(0, NULL, self.usecs, sltimer_proc, <void*>self)
