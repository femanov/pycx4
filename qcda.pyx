#cython: profile=False, linetrace=False
#cython: c_string_type=bytes, c_string_encoding=ascii
#cython: boundscheck=False, wraparound=False

from PyQt4.QtCore import QObject, pyqtSignal

# textual include of basic level cda classes
include 'pycdabase.pxi'

# Signal container to bypass inheritance from QObject
# to be encapsulated in Qt channel-like classes
class Signaler(QObject):
    valueChanged = pyqtSignal(object)
    valueMeasured = pyqtSignal(object)

    def __init__(self):
        super(Signaler, self).__init__()


# signaled base channel PyQt-base implementation

cdef class cda_sigbase_chan(cda_base_chan):
    # signal containers
    cdef:
        object signaler
        public object valueChanged
        public object valueMeasured

    def __cinit__(self, *args):
        #super(cda_sigbase_chan, self).__init__(*args)
        # encapsulating Signaler QObject
        self.signaler = Signaler()
        self.valueChanged = self.signaler.valueChanged
        self.valueMeasured = self.signaler.valueMeasured

# textual include of user level classes
include 'pycdauser.pxi'
