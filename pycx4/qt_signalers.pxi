# Signal container to bypass inheritance from QObject
# to be encapsulated in Qt channel-like classes
class ChanSignaler(QObject):
    valueChanged = pyqtSignal(object)
    valueMeasured = pyqtSignal(object)

    def __init__(self):
        super(ChanSignaler, self).__init__()

class ContSignaler(QObject):
    serverCycle = pyqtSignal(object)

    def __init__(self):
        super(ContSignaler, self).__init__()
