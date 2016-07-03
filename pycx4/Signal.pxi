# simple cycthon implementation of signals
from cpython cimport Py_INCREF,Py_DECREF

cdef class Signal:
    cdef:
        void **callbacks
        int cnum

# let's rely on default definitions, ha-ha. if any problems - will change it
    def __cinit__(self):
        self.callbacks = NULL
        self.cnum = 0

    def __dealloc__(self):
        cdef int ind
        for ind in range(self.cnum):
            Py_DECREF(<object>(self.callbacks[ind]))
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
        Py_INCREF(callback)

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
        Py_DECREF(callback)

    cpdef emit(self, object arg) with gil:
        cdef int ind
        for ind in range(self.cnum):
            (<object>(self.callbacks[ind]))(arg)
