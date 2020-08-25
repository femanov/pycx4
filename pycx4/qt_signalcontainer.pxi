# Signal container to bypass inheritance from QObject
# to be encapsulated in Qt channel-like classes

class SigContainer(QObject):
    def __new__(cls, *args):
        cont = type("syg_cont", (QObject, ), {
                 "sig": pyqtSignal(args)})
        inst = cont()
        inst.emit, inst.connect, inst.disconnect = inst.sig.emit, inst.sig.connect, inst.sig.disconnect
        return inst


Signal = SigContainer


# class SignalContainer(QObject):
#     signal = pyqtSignal(object)
#
#     def __init__(self):
#         super().__init__()
#         # next lines is possible after initialization
#         self.connect = self.signal.connect
#         self.disconnect = self.signal.disconnect
#         self.emit = self.signal.emit

