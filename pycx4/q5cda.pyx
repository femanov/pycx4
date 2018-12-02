# PyQtX reference is only here, may be nedd to do it more universal

from PyQt5.QtCore import QObject, pyqtSignal
from PyQt5.QtNetwork import QAbstractSocket

include 'imports.pxi'

include 'qt_signalcontainer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='Qt'

include 'cda_common.pxi'
