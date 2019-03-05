

# cx-cx gateway and basic processing channels

# pass value
cdef class PassGW:
    cdef:
        object in_chan, out_chan, last_val

    def __init__(self, str in_name, str out_name, **kwargs):
        dtype = kwargs.get('dtype', 'double')
        max_nelems = kwargs.get('max_nelems', 1)

        self.in_chan = cfactory.create_chan(in_name, dtype, max_nelems, **kwargs)
        self.out_chan = cfactory.create_chan(out_name, dtype, max_nelems, **kwargs)

        self.in_chan.valueMeasured.connect(self.in_c_proc)
        self.out_chan.valueMeasured.connect(self.out_c_proc)

        self.last_val = None

    cpdef void in_c_proc(self, chan):
        self.last_val = self.in_chan.val
        self.out_chan.setValue(self.in_chan.val)

    cpdef void out_c_proc(self, chan):
        if chan.val == self.last_val or self.last_val is None:
            return
        self.out_chan.setValue(self.last_val)


cdef class ProcGW:
    cdef:
        object in_chan, out_chan

    def __init__(self, str in_name, str out_name, **kwargs):
        dtype = kwargs.get('dtype', 'double')
        max_nelems = kwargs.get('max_nelems', 1)

        self.in_chan = cfactory.create_chan(in_name, dtype, max_nelems, **kwargs)
        self.out_chan = cfactory.create_chan(out_name, dtype, max_nelems, **kwargs)

        self.in_chan.valueMeasured.connect(self.in_c_proc)
        self.out_chan.valueMeasured.connect(self.out_c_proc)

    cpdef void in_c_proc(self, chan):
        pass

    cpdef void out_c_proc(self, chan):
        pass

    def in2out(in_val):
        pass
