from cx4.cxscheduler cimport sl_main_loop, sl_break, sl_at_select_proc, sl_set_select_behaviour
cimport cx4.cxscheduler as sl

cpdef main_loop():
    sl_main_loop()

cpdef break_():
    sl_break()


# some deprecated code to
# def select_interrupt_action():
#     pass
#
# cdef void at_select() with gil:
#     select_interrupt_action()
#
# sl_set_select_behaviour(<sl_at_select_proc>NULL, <sl_at_select_proc>at_select, 100000)

SL_RD = sl.SL_RD
SL_WR = sl.SL_WR
SL_EX = sl.SL_EX
SL_CE = sl.SL_CE

