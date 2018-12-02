# PyQtX reference is only here, may be nedd to do it more universal

from PyQt4.QtCore import QObject, pyqtSignal
from PyQt4.QtNetwork import QAbstractSocket

include 'imports.pxi'


include 'qt_signalcontainer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='Qt'

include 'cda_common.pxi'