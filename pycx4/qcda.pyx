from PyQt4.QtCore import QObject, pyqtSignal
from cx4.cda cimport *
from libc.stdlib cimport realloc, free, malloc
from libc.string cimport memmove

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
# textual include of user level classes
include 'pycdauser.pxi'
