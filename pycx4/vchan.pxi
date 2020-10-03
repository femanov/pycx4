# vector-data channel class
cdef class VChan(BaseChan):
    cdef:
        readonly object val  # showing data to numpy
        readonly array.array cval# that one really owns data
        #readonly np.ndarray background, bg_val
        readonly int nelems
        int average
        int bg_count
        bint change_sign, dont_update, getting_background, bg_apply, bg_ready

    def __cinit__(self, str name, **kwargs):
        self.change_sign = kwargs.get('change_sign', False)
        self.getting_background = False
        self.bg_ready = False
        self.cval = array.array(cxdtype2pycode(self.dtype))
        self.init_val(1)

    cdef void init_val(self, int size):
        array.resize(self.cval, size)
        if using_numpy:
            self.val = np.asarray(self.cval)
        self.nelems = size

    cdef void cb(self):
        cdef int nelems = self.current_nelems()
        if self.nelems != nelems:
            self.init_val(nelems)

        c_len = self.get_data(0, self.itemsize * nelems, self.cval.data.as_voidptr)
        nelems_read = int(c_len/self.itemsize)
        if self.change_sign:
            self.val *= -1 # unlike what happens in python here it makes multiplication inplace

        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    # this version can work with almost any contigouos buffer
    cpdef void setValue(self, atype[::1] value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        cdef cxdtype_t dtype
        if atype is float64: dtype = CXDTYPE_DOUBLE
        elif atype is float32: dtype = CXDTYPE_SINGLE
        elif atype is int32: dtype = CXDTYPE_INT32
        elif atype is int16: dtype = CXDTYPE_INT16
        elif atype is int8: dtype = CXDTYPE_INT8
        elif atype is uint32: dtype = CXDTYPE_UINT32
        elif atype is uint16: dtype = CXDTYPE_UINT16
        elif atype is uint8: dtype = CXDTYPE_UINT8
        elif atype is char8: dtype = CXDTYPE_TEXT
        elif atype is char32: dtype = CXDTYPE_UCTEXT

        self.snd_data(dtype, value.size, <void*>&value[0])

    # cpdef void setValue(self, np.ndarray value):
    #     if value.size > self.max_nelems:
    #         raise Exception('value size greater than channel.max_nelems')
    #     dtype = np2cxdtype(value.dtype)
    #     self.snd_data(dtype, value.size, <void*>value.data)

    # cpdef void getBackgroung(self):
    #     self.getting_background = True
    #     self.bgcount = 10
    #     self.bg_apply = False
    #     self.bg_ready = False
    #     self.background = np.zeros(self.nelems)
    #     self.bg_val = np.empty(self.nelems)
    #     print("gtting background")
    #
    # cpdef void setApplyBackground(self):
    #     if not self.bg_ready:
    #         return


