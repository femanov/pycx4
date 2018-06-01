

cdef class CdaObject:
    cdef:
        event **events
        int evnum

    def __init__(self):
        self.events = NULL
        self.evnum = 0

    def __dealloc__(self):
        if self.evnum > 0:
            free(self.events)
            self.events = NULL
            self.evnum = 0

    cdef int add_event(self,int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            int x
            event *ev_t
            event *ev
            void *tmp

        if evmask == 0 or evproc == NULL:
            # event will not run
            return 0
        for x in range(self.evnum):
            ev_t = self.events[x]
            if ev_t.evmask == evmask and ev_t.evproc == evproc and \
            ev_t.objptr == objptr and ev_t.userptr == userptr:
                # event already exists
                return 0

        ev = <event*>malloc(sizeof(event))
        if not ev: raise MemoryError()

        ev.evmask, ev.evproc, ev.objptr, ev.userptr = evmask, evproc, objptr, userptr

        tmp = realloc(self.events, sizeof(event*) * (self.evnum + 1) )
        if not tmp: raise MemoryError()
        self.events = <event**>tmp
        self.events[self.evnum] = ev

        self.register_event(ev)
        self.evnum += 1
        return 1

    cdef int del_event(self, int evmask, void *evproc, void *objptr, void *userptr):
        cdef:
            event ev
            int ev_ind = -1
            int x

        for x in range(self.evnum):
            if self.events[x].evmask == evmask and self.events[x].evproc == evproc and \
            self.events[x].objptr == objptr and self.events[x].userptr == userptr:
                ev_ind = x
                break

        if ev_ind < 0: # event does not exist
            return 0
        self.unregister_event(self.events[ev_ind])
        if self.evnum == 1:
            free(self.events[ev_ind])
            # looks like self.events[ev_ind] = NULL - not needed here
            free(self.events)
            self.events = NULL
        else:
            memmove(&(self.events[ev_ind]), &(self.events[self.evnum-1]), sizeof(event*))
            tmp = realloc(self.events, sizeof(event*) * (self.evnum - 1))
            if not tmp: raise MemoryError()
            self.events = <event**>tmp
        self.evnum -= 1
        return 1

    cdef void register_event(self, event *ev):
        return

    cdef void unregister_event(self, event *ev):
        return
