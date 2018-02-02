# PyQtX reference is only here, may be nedd to do it more universal

from PyQt5.QtCore import QObject, pyqtSignal
from PyQt5.QtNetwork import QAbstractSocket

include 'imports.pxi'

include 'qt_signalcontainer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='Qt'
# textual include of basic level cda classes
include 'cxdtype.pxi'

include 'event.pxi'

include 'cdaobject.pxi'

include 'context.pxi'

cdef Context default_context=Context()

include 'basechan.pxi'

include 'dchan.pxi'
include 'chan.pxi'
include 'vchan.pxi'
include 'strchan.pxi'

include 'cda_all.pxi'