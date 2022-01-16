from cx4.cxscheduler cimport sl_main_loop, sl_break
cimport cx4.cxscheduler as sl

SL_RD = sl.SL_RD
SL_WR = sl.SL_WR
SL_EX = sl.SL_EX
SL_CE = sl.SL_CE


cpdef main_loop():
    sl_main_loop()

cpdef break_():
    sl_break()


