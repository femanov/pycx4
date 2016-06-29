# from cxscheduler cimport sl_main_loop, sl_break
#
# def py_sl_main_loop():
#     sl_main_loop()
#
# def py_sl_break():
#     sl_break()

#from scheduler import *

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='CdaSignal'
# textual include of basic level cda classes
include 'pycdabase.pxi'
# textual include of user level classes
include 'pycdauser.pxi'

include 'sltimer.pxi'
