#!/usr/bin/env python


# imports for testing
import sys
from PyQt4 import QtCore

import pycx.qcda as cda
import signal

signal.signal(signal.SIGINT, signal.SIG_DFL)

app = QtCore.QCoreApplication(sys.argv)


chan = cda.vchan("cx::localhost:0.ic.ring.kickers.adc1.c1.u", cda.PY_CXDTYPE_DOUBLE, 1024)

print chan.ref


sys.exit(app.exec_())