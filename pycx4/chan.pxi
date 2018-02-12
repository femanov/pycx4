# general channel (any cx type)
cdef class Chan(BaseChan):
    cdef:
        readonly object val, prev_val

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, **kwargs):
        BaseChan.__init__(self, name, context, dtype, **kwargs)

    cdef void cb(self):
        cdef CxAnyVal_t aval
        self.prev_val = self.val
        self.get_data(0, self.itemsize, <void*>&aval)
        self.val = aval_value(&aval, self.dtype)
        if self.val != self.prev_val or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef void setValue(self, value):
        cdef CxAnyVal_t aval
        aval_setvalue(value, &aval, self.dtype)
        self.snd_data(self.dtype, 1, <void*>&aval)
