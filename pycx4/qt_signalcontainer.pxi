# Signal container to bypass inheritance from QObject
# to be encapsulated in Qt channel-like classes

class SigContainer(QObject):
    def __new__(cls, *args):
        sig = pyqtSignal(args)
        cont = type('sig_cont', (QObject, ), {
                 'sig': pyqtSignal(args)})
        inst = cont()
        inst.emit, inst.connect, inst.disconnect = inst.sig.emit, inst.sig.connect, inst.sig.disconnect
        return inst


Signal = SigContainer

