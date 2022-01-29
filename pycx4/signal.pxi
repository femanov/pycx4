# Simple cython implementation of Qt-like signals.
# Created in order to reuse some code in Qt and CX-native applications
# This class don't enforce signal/slot argument types.
# Slot can be connected only once, next connections are ignored.
# name and owner can be passed through kwargs, once were used for debugging, may be need to remove it.

from cpython cimport Py_INCREF,Py_DECREF

@cython.freelist(10)
cdef class InstSignal:
    """
    Instance signal
    """
    cdef:
        void **callbacks
        int cnum
        str name
        str owner

    def __cinit__(self, *args, **kwargs):
        # name and owner once were needed for debugging
        self.name = kwargs.get('name', None)
        self.owner = kwargs.get('owner', None)
        self.callbacks = NULL
        self.cnum = 0

    def __dealloc__(self):
        cdef int ind
        for ind in range(self.cnum):
            Py_DECREF(<object>(self.callbacks[ind]))
        free(self.callbacks)

    cpdef connect(self, slot):
        cdef:
            void *tmp
            int ind
        if not callable(slot):
            raise ValueError('callable was expected')
        for ind in range(self.cnum):
            if slot == <object>self.callbacks[ind]:
                #
                return
        tmp = realloc(<void*>self.callbacks, sizeof(void*) * (self.cnum+1))
        if not tmp: raise MemoryError()
        self.callbacks = <void**>tmp
        self.callbacks[self.cnum] = <void*>slot
        self.cnum += 1
        Py_INCREF(slot)

    cpdef disconnect(self, slot):
        cdef:
            void *tmp
            int ind
        for ind in range(self.cnum):
            if slot == <object>self.callbacks[ind]:
                if self.cnum == 1:
                    free(self.callbacks)
                else:
                    memmove(&(self.callbacks[ind]), &(self.callbacks[self.cnum-1]), sizeof(void*))
                    tmp = realloc(self.callbacks, sizeof(void*) * (self.cnum-1))
                    if not tmp: raise MemoryError()
                    self.callbacks = <void**>tmp
                self.cnum -= 1
        Py_DECREF(slot)

    def __call__(self, *args):
        self.emit(*args)

    def emit(self, *args):
        cdef int ind
        for ind in range(self.cnum):
            (<object>(self.callbacks[ind]))(*args)


import weakref

cdef class ClassSignal:
    """
    The class signal allows a signal to be set on a class rather than an instance.
    This emulates the behavior of a PyQt signal
    """
    cdef readonly:
        dict _map

    def __cinit__(self):
        self._map = {}

    def __get__(self, instance, owner):
        if instance is None:
            # When we access ClassSignal element on the class object without any instance,
            # we return the ClassSignal itself
            return self
        tmp = self._map.setdefault(self, weakref.WeakKeyDictionary())
        return tmp.setdefault(instance, InstSignal())

    def __set__(self, instance, value):
        raise RuntimeError("Cannot assign to a Signal object")

