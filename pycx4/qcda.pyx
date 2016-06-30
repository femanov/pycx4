from PyQt4.QtCore import QObject, pyqtSignal

include 'qt_signalers.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='Qt'
# textual include of basic level cda classes
include 'pycdabase.pxi'
# textual include of user level classes
include 'pycdauser.pxi'
