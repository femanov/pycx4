from cxscheduler cimport *

def py_sl_main_loop():
    sl_main_loop()

def py_sl_break():
    sl_break()

include 'pycdabase.pxi'

# simple implementation of Qt-like multiply callback handler
# for use with
cdef class cda_signal:
    cdef:
        void **callbacks
        int cnum

# let's rely on default definitions, ha-ha. if any problems - will change it
#    def __cinit__(self):
#        self.callbacks = NULL
#        self.cnum = 0

    def __dealloc__(self):
        free(self.callbacks)

    cpdef connect(self, callback):
        cdef:
            void *tmp
            int ind
        if not callable(callback): raise Exception('A function was expected')
        for ind in range(self.cnum):
            if callback == <object>self.callbacks[ind]:
                return
        tmp = realloc(<void*>self.callbacks, sizeof(void*) * (self.cnum+1))
        if not tmp: raise MemoryError()
        self.callbacks = <void**>tmp
        self.callbacks[self.cnum] = <void*>callback
        self.cnum += 1

    cpdef disconnect(self, callback):
        cdef:
            void *tmp
            int ind
        for ind in range(self.cnum):
            if callback == <object>self.callbacks[ind]:
                if self.cnum == 1:
                    free(self.callbacks)
                else:
                    memmove(&(self.callbacks[ind]), &(self.callbacks[self.cnum-1]), sizeof(void*))
                    tmp = realloc(self.callbacks, sizeof(void*) * (self.cnum-1))
                    if not tmp: raise MemoryError()
                    self.callbacks = <void**>tmp
                self.cnum -= 1

    cpdef emit(self, object arg):
        cdef int ind
        for ind in range(self.cnum):
            (<object>(self.callbacks[ind]))(arg)


# console client signaled base chan implementation
cdef class cda_sigbase_chan(cda_base_chan):
    cdef readonly:
        cda_signal valueMeasured
        cda_signal valueChanged

    def __cinit__(self, *args):
        self.valueMeasured = cda_signal()
        self.valueChanged = cda_signal()


# textual include of user level classes
include 'pycdauser.pxi'