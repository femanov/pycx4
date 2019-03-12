# scalar double channel
cdef class DChan(BaseChan):
    """
    One-double channel

    val - double last-known value
    prev_val - previous value
    tolerance - tolerance of emitting valueChanged signal
    """
    cdef:
        # all general properties defined in base classes
        readonly double val, prev_val, tolerance

    def __init__(self, str name, **kwargs):
        kwargs['dtype'] = cx.CXDTYPE_DOUBLE
        BaseChan.__init__(self, name, **kwargs)
        self.tolerance = 0.0

    cdef void cb(self):
        self.prev_val = self.val
        self.check_exception(cda_get_dcval(self.ref, &self.val))
        if abs(self.val - self.prev_val) > self.tolerance or self.first_cycle:
            self.valueChanged.emit(self)
        self.valueMeasured.emit(self)
        self.first_cycle = False

    cpdef void setValue(self, double value):
        self.check_exception( cda_set_dcval(self.ref, value) )

    cpdef void setTolerance(self, double new_tolerance):
        self.tolerance = new_tolerance
