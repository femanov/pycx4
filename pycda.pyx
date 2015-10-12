from cxscheduler cimport *

def py_sl_main_loop():
    sl_main_loop()

def py_sl_break():
    sl_break()

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='cda_signal'
# textual include of basic level cda classes
include 'pycdabase.pxi'
# textual include of user level classes
include 'pycdauser.pxi'