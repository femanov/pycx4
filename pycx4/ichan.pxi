# scalar int32 channel with simplified interface
cdef class IChan(BaseChan):
    cdef:
        # all general properties defined in base classes
        readonly int val, prev_val, tolerance

    def __init__(self, str name, **kwargs):
        kwargs['dtype'] = cx.CXDTYPE_UINT32
        BaseChan.__init__(self, name, **kwargs)
        self.tolerance = 0

    cdef void cb(self):
        self.prev_val = self.val
        cda_check_exception(cda_get_icval(self.ref, &self.val))
        if abs(self.val - self.prev_val) > self.tolerance or self.first_cycle:
            self.valueChanged.emit(self)
        self.valueMeasured.emit(self)
        self.first_cycle = False

    cpdef void setValue(self, int value):
        cda_check_exception( cda_set_icval(self.ref, value) )

    cpdef void setTolerance(self, int new_tolerance):
        self.tolerance = new_tolerance
