from cx4.cxscheduler cimport *

cpdef main_loop():
    sl_main_loop()

cpdef break_():
    sl_break()


#  required to react to signals in case of daemon
def select_interrupt_action():
    pass

cdef void at_select():
    select_interrupt_action()

sl_set_select_behaviour(<sl_at_select_proc>NULL, <sl_at_select_proc>at_select, 0)