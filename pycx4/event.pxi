# auxilary definitions and functions for CX events handling

# struct to extend private pointer
ctypedef struct event:
    int evmask    # cda eventmask
    void *evproc  # pointer to proc function
    void *objptr  # pointer to sender object
    void *userptr # pointer to user data


# event handling functions
# check if event can happen
cdef inline int event_feasible(event *ev):
    if ev.evmask == 0 or ev.evproc == NULL or ev.objptr == NULL:
        return 0
    return 1

# compare ex1 and ev2
cdef inline int cmp_events(event *ev1, event *ev2):
    if ev1.evmask == ev2.evmask and ev1.evproc == ev2.evproc and \
        ev1.objptr == ev2.objptr and ev1.userptr == ev2.userptr:
        return 0
    return 1
