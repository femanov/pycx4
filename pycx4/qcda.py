
import sys
import importlib

qts = ['PyQt5', 'PyQt4']
QT_LIB = None
cda = None

for lib in qts:
    if lib in sys.modules:
        QT_LIB = lib
        break
if QT_LIB is None:
    for lib in qts:
        try:
            importlib.import_module(lib)
            QT_LIB = lib
            break
        except ImportError:
            pass
if QT_LIB is None:
    ImportError("PyQt not found. it's required for qcda")

if QT_LIB == 'PyQt5':
    import q5cda as cda

elif QT_LIB == 'PyQt4':
    import q4cda as cda
