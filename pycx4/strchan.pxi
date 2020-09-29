# chan to transfer python string
cdef class StrChan(BaseChan):
    cdef:
        readonly str val, prev_val
        char *cval

    def __cinit__(self, str name, **kwargs):
        self.cval = <char*>malloc(self.max_nelems)
        if not self.cval: raise MemoryError()
        self.val,self.prev_val = '', ''

    def __dealloc__(self):
        if not self.cval:
            free(self.cval)
            self.cval = NULL

    cdef void cb(self):
        self.prev_val = self.val
        c_len = self.get_data(0, self.max_nelems, <void*>self.cval)
        self.val = (<bytes>self.cval[:c_len]).decode('UTF-8')
        self.valueMeasured.emit(self)
        if self.val != self.prev_val:
            self.valueChanged.emit(self)

    cpdef void setValue(self, str value):
        bv = value.encode('UTF-8')
        cdef char *v = bv
        self.snd_data(CXDTYPE_TEXT, len(bv), <void*>v)






