#!/usr/bin/env python


# imports for testing
import time
import sys
from PyQt4 import QtCore

import pycx.qcda as cda
import signal

signal.signal(signal.SIGINT, signal.SIG_DFL)


t1 = time.time()

nchans = 10
i = 0

def printval(chan):
    global i
    i += 1
    if i == 50:
        print chan.val
        t2 = time.time()
        print "time = %f " % (t2-t1)
        app.quit()


app = QtCore.QCoreApplication(sys.argv)


chans = []
for x in range(nchans):
    chans.append(cda.sdchan("cx::mid:60.NAME%d" % x))


for x in chans:
    x.valueMeasured.connect(printval)


sys.exit(app.exec_())