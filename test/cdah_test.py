#!/usr/bin/env python
import signal

import sys
import pycx.qcda as cda
from PyQt4 import QtCore
import time


def new_data(chan1):
    "running slot"
    t1 = time.time()
    for x in xrange(1000000):
        chan1.setValue(0.0)
    t2 = time.time()

    print "settime = %f" % (t2-t1)
    #app.quit()


signal.signal(signal.SIGINT, signal.SIG_DFL)

app = QtCore.QCoreApplication(sys.argv)

#cont = ccda.cda_context()
# None passed to chan - default context will be used
chan = cda.sdchan("linmagx.mc-c208.n45_set")
chan.valueMeasured.connect(new_data)

sys.exit(app.exec_())