from cx4.cxscheduler cimport sl_main_loop, sl_break

def main_loop():
    sl_main_loop()

def break_():
    sl_break()

include 'CdaSignal.pxi'

include 'sltimer.pxi'
