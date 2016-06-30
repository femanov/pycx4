from cx4.cxscheduler cimport sl_main_loop, sl_break

cpdef main_loop():
    sl_main_loop()

cpdef break_():
    sl_break()

include 'Signal.pxi'
include 'Timer.pxi'
