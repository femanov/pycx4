from PyQt4.QtCore import QObject, pyqtSignal

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='pyqtSignal'
# textual include of basic level cda classes
include 'pycdabase.pxi'
# textual include of user level classes
include 'pycdauser.pxi'
