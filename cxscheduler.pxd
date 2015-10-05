
cdef extern from "cxscheduler.h" nogil:
    enum:
       SL_RD = 1 #,  // Watch when descriptor is ready for read
       SL_WR = 2 #,  // Watch when descriptor is ready for write
       SL_EX = 4 #,  // Watch descriptor for exceptions (in fact -- OOB data)
       SL_CE = 8 #,  // Watch for Connect Errors.  That's a hint for Xh_cxscheduler exclusively

    ctypedef int sl_tid_t
    ctypedef int sl_fdh_t

    ctypedef void (*sl_tout_proc)(int uniq, void *privptr1, sl_tid_t tid, void *privptr2)
    ctypedef void (*sl_fd_proc)(int uniq, void *privptr1, sl_fdh_t fdh, int fd, int mask, void *privptr2)

    # don't know how to define struct timeval *when
    #cdef sl_tid_t sl_enq_tout_at(int uniq, void *privptr1,
    #                         struct timeval *when,
    #                         sl_tout_proc cb, void *privptr2)

    cdef sl_tid_t sl_enq_tout_after(int uniq, void *privptr1,
                                int             usecs,
                                sl_tout_proc cb, void *privptr2)

    cdef int sl_deq_tout(sl_tid_t tid)

    cdef sl_fdh_t  sl_add_fd(int uniq, void *privptr1,
                         int fd, int mask, sl_fd_proc cb, void *privptr2)

    cdef int sl_del_fd(sl_fdh_t fdh)

    cdef int sl_set_fd_mask(sl_fdh_t fdh, int mask)

    cdef int sl_main_loop()
    cdef int sl_break()


    #/* Note:
    #   the sl_set_select_behaviour() is implemented in
    #   CLASSIC, select-based cxscheduler.c only */

    ctypedef void (*sl_at_select_proc)()

    cdef int sl_set_select_behaviour(sl_at_select_proc  before,
                             sl_at_select_proc  after,
                             int usecs_idle)

    ctypedef void (*sl_on_timeback_proc)()
    cdef int sl_set_on_timeback_proc(sl_on_timeback_proc proc)

    ctypedef int (*sl_uniq_checker_t)(const char *func_name, int uniq)

    cdef void sl_set_uniq_checker(sl_uniq_checker_t checker)
    cdef void sl_do_cleanup(int uniq)
