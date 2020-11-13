

# Utility functions to avoid dependencies
# this functions do not perform any checks... to be used with precautions
# # v * a inplace
# def vector_mult(atype[::1] v, double a):
#     cdef int i
#     for i in range(len(v)):
#         v[i] = <atype>(v[i] * a)
#
# def vector_iadd(atype[::1] v1, atype2[::1] v2):
#     cdef int i
#     for i in range(len(v1)):
#         v1[i] += <atype>v2[i]
#
# def vector_isub(double[::1] v1, double[::1] v2):
#     cdef int i
#     for i in range(len(v1)):
#         v1[i] -= v2[i]
#
# def vector_sub(double[::1] vout, atype[::1] v1, double[::1] v2):
#     cdef int i
#     for i in range(len(v1)):
#         vout[i] = <double>v1[i] - v2[i]
#
# def avg(atype[::1] vin, int wi, int wf):
#     cdef:
#         int i
#         double a=0
#     for i in range(wi, wf):
#         a += vin[i]
#     a /= wf-wi
#     return a

# this supports just double, but faster and lighter
# v * a inplace
cdef vector_mult(double[::1] v, double a):
    cdef int i
    for i in range(len(v)):
        v[i] = (v[i] * a)

cdef vector_iadd(double[::1] v1, double[::1] v2):
    cdef int i
    for i in range(len(v1)):
        v1[i] += v2[i]

cdef vector_isub(double[::1] v1, double[::1] v2):
    cdef int i
    for i in range(len(v1)):
        v1[i] -= v2[i]

cdef vector_sub(double[::1] vout, double[::1] v1, double[::1] v2):
    cdef int i
    for i in range(len(v1)):
        vout[i] = v1[i] - v2[i]

cdef avg(double[::1] vin, int wi, int wf):
    cdef:
        int i
        double a=0
    for i in range(wi, wf):
        a += vin[i]
    a /= wf-wi
    return a



# vector-data channel class with some data processing capabilities
cdef class VPChan(VChan):
    cdef:
        readonly object avg_val, bg_val
        readonly array.array avg_aval, bg_aval, bg
        readonly object avgReady, bgReady # extra signals
        readonly int reg_s, reg_f
        readonly double reg_avg

        int n_avg, avg_count
        int bg_count, bg_anum
        bint change_sign, dont_update, bg_apply, bg_ready

    def __cinit__(self, str name, **kwargs):
        self.change_sign = kwargs.get('change_sign', False)
        self.avgReady = Signal(object)
        self.bgReady = Signal(object)
        self.bg_ready = False
        self.bg_count = -1
        self.n_avg = 1
        self.avg_aval = array.array('d')

    cdef void resize_avg_val(self, int size):
        array.resize(self.avg_aval, size)
        if using_numpy:
            self.avg_val = np.asarray(self.avg_aval)
        self.avg_count = 0 # this to reset averaging

    cdef void reset_bg(self):
        self.bg_ready = False
        self.bg = None

    cdef void cb(self):
        cdef int nelems = self.current_nelems()
        if self.nelems != nelems:
            self.resize_val(nelems)
            if self.n_avg > 1:
                self.resize_avg_val(nelems)
            if self.bg_ready:
                self.reset_bg()
        c_len = self.get_data(0, self.itemsize * nelems, self.aval.data.as_voidptr)

        if self.change_sign:
            vector_mult(self.aval, -1.0)

        if self.bg_count > 0:
            vector_iadd(self.bg, self.aval)
            self.bg_count -= 1
            print("getting bg, steps left: ", self.bg_count)
        if self.bg_count == 0 and not self.bg_ready:
            vector_mult(self.bg, 1.0/self.bg_anum)
            self.bg_ready = True
            self.bgReady.emit(self)

        if self.bg_apply and self.bg_ready:
            vector_sub(self.bg_aval, self.aval, self.bg)

        if self.n_avg > 1:
            if self.avg_count == 0:
                array.zero(self.avg_aval)
            vector_iadd(self.avg_aval, self.aval)
            self.avg_count += 1
            if self.avg_count == self.n_avg:
                vector_mult(self.avg_aval, 1.0/self.n_avg)
                if self.bg_apply:
                    vector_isub(self.avg_aval, self.bg)
                self.avgReady.emit(self)
                self.avg_count = 1

        if self.reg_f > 0:
            self.reg_avg = avg(self.aval, self.reg_s, self.reg_f)

        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setAveraging(self, int n_avg):
        if n_avg == self.n_avg or n_avg < 1:
            return
        self.n_avg = n_avg
        if n_avg == 1:
            self.avg_aval = None
        if n_avg > 1:
            self.resize_avg_val(self.nelems)

    cpdef void getBg(self, bg_anum):
        self.bg = array.array('d')
        array.resize(self.bg, self.nelems)
        array.zero(self.bg)
        self.bg_count = bg_anum
        self.bg_anum = bg_anum
        self.bg_ready = False

    cpdef void setBgApply(self, bint state):
        self.bg_apply = state
        if state:
            self.bg_aval = array.array('d')
            array.resize(self.bg_aval, self.nelems)
            if using_numpy:
                self.bg_val = np.asarray(self.bg_aval)
        else:
            self.bg_aval = None

    cpdef void dropBg(self):
        self.bg = None
        self.bg_ready = False
        self.bg_count = -1

    cpdef void setRegProc(self, reg_s, reg_f):
        self.reg_s = reg_s
        self.reg_f = reg_f




