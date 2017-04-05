# auxilary definitions and functions for CX events handling

# struct to extend private pointer
ctypedef struct event:
    int evmask    # cda eventmask
    void *evproc  # pointer to proc function
    void *objptr  # pointer to sender object
    void *userptr # pointer to user data

