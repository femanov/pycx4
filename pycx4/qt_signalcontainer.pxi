# Signal container to bypass inheritance from QObject
# to be encapsulated in Qt channel-like classes

class SignalContainer(QObject):
    signal = pyqtSignal(object)

    def __init__(self):
        super(SignalContainer, self).__init__()
