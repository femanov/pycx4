import sys

__all__ = []

if 'pycx4.qcda' in sys.modules or 'PyQt4' in sys.modules or 'PyQt5' in sys.modules:
    import pycx4.qcda
    from pycx4.qcda import *
    __all__ += pycx4.qcda.__all__
else:
    import pycx4.pycda
    from pycx4.pycda import *
    __all__ += pycx4.pycda.__all__
