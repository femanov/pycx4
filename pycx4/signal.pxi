# simple cycthon implementation of signals
from cpython cimport Py_INCREF,Py_DECREF

@cython.freelist(5)
cdef class Signal:
    cdef:
        void **callbacks
        int cnum

    def __cinit__(self, *args, **kwargs):
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
                return
        tmp = realloc(<void*>self.callbacks, sizeof(void*) * (self.cnum+1))
        if not tmp: raise MemoryError()
        self.callbacks = <void**>tmp
        self.callbacks[self.cnum] = <void*>slot
        self.cnum += 1
        Py_INCREF(slot)

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

    def __call__(self, *args):
        self.emit(*args)

    def emit(self, *args):
        #------- sender?
        # def _get_sender():
        #     """Try to get the bound, class or module method calling the emit."""
        #     import inspect
        #     import sys
        #
        #     prev_frame = sys._getframe(2)
        #     func_name = prev_frame.f_code.co_name
        #
        #     # Faster to try/catch than checking for 'self'
        #     try:
        #         return getattr(prev_frame.f_locals['self'], func_name)
        #
        #     except KeyError:
        #         return getattr(inspect.getmodule(prev_frame), func_name)
        #
        # # Get the sender
        # try:
        #     _sender = _get_sender()
        #
        # # Account for when func_name is at '<module>'
        # except AttributeError:
        #     _sender = None
        #
        # # Handle unsupported module level methods for WeakMethod.
        # # TODO: Support module level methods.
        # except TypeError:
        #     _sender = None

        if self.name:
            print(f'emit call, name: {self.name}, owner: {self.owner}, cbnum: {self.cnum}, value:{args[0]}')
        cdef int ind
        for ind in range(self.cnum):
            (<object>(self.callbacks[ind]))(*args)

