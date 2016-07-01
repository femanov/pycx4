

cdef class CdaObject:
    cdef:
        event *events
        int evnum

    def __init__(self):
        self.events = NULL
        self.evnum = 0

    def __dealloc__(self):
        free(self.events)

    cdef int add_event(self,int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            event ev
            void *tmp
        ev.evmask, ev.evproc, ev.objptr, ev.userptr = evmask, evproc, objptr, userptr

        if event_feasible(&ev) == 0 or self.search_event(&ev) > -1:
            # event will not run or already exist
            return 0
        tmp = realloc(self.events, sizeof(event) * (self.evnum + 1) )
        if not tmp: raise MemoryError()
        self.events = <event*>tmp
        self.events[self.evnum] = ev
        self.register_event(&self.events[self.evnum])
        self.evnum += 1
        return 1

    cdef int del_event(self, int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            event ev
            int ev_ind

        ev.evmask, ev.evproc, ev.objptr, ev.userptr = evmask, evproc, objptr, userptr
        ev_ind = self.search_event(&ev)
        if ev_ind < 0: # event does not exist
            return 0
        self.unregister_event(&(self.events[ev_ind]))
        if self.evnum == 1:
            free(self.events)
        else:
            memmove(&(self.events[ev_ind]), &(self.events[self.evnum-1]), sizeof(event))
            tmp = realloc(self.events, sizeof(event) * (self.evnum - 1))
            if not tmp: raise MemoryError()
            self.events = <event*>tmp
        self.evnum -= 1
        return 1

    cdef int search_event(self, event *ev):
        for ind in range(self.evnum):
            if cmp_events(&self.events[ind], ev) == 0:
                return ind
        return -1

    cdef void register_event(self, event *ev):
        return

    cdef void unregister_event(self, event *ev):
        return
