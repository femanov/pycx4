# scalar double channel
cdef class DChan(BaseChan):
    cdef:
        # all general properties defined in base classes
        readonly double val, prev_val, tolerance

    def __init__(self, str name, object context=None, **kwargs):
        BaseChan.__init__(self, name, context, **kwargs)
        self.tolerance = 0.0

    cdef void cb(self):
        self.prev_val = self.val
        cda_check_exception(cda_get_dcval(self.ref, &self.val))
        if abs(self.val - self.prev_val) > self.tolerance or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef void setValue(self, double value):
        cda_check_exception( cda_set_dcval(self.ref, value) )

    cpdef void setTolerance(self, double new_tolerance):
        self.tolerance = new_tolerance
