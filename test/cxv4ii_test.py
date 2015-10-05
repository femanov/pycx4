#!/usr/bin/env python


# imports for testing
import time
import sys
from PyQt4 import QtCore

import pycx.qcda as cda
import signal


nchans = 10000
i = 0

def printval(chan):
    global i
    i += 1
    if i == 1000000:
        print chan.val
        t2 = time.time()
        print 'time1 = %f ' % (t1-t0)
        print "time = %f " % (t2-t1)
        app.quit()

signal.signal(signal.SIGINT, signal.SIG_DFL)

t0 = time.time()


app = QtCore.QCoreApplication(sys.argv)

context = cda.cda_context("localhost:1.NAME")

chans = []

for x in range(nchans):
    chans.append(cda.sdchan( "%d" % x, context))

for x in chans:
    x.valueChanged.connect(printval)

t1 = time.time()

sys.exit(app.exec_())