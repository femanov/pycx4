#!/usr/bin/env python

import time
import signal
import pycx4.pycda as cda

signal.signal(signal.SIGINT, signal.SIG_DFL)

nchans = 50
i = 0

def printval(chan):
    global i
    i += 1
    if i == 100000:
        print chan.val
        t2 = time.time()
        print 'time1 = %f ' % (t1-t0)
        print "time2 = %f " % (t2-t1)
        cda.py_sl_break()

t0 = time.time()

context = cda.cda_context("localhost:2.NAME")

chans = []

for x in range(nchans):
    chans.append(cda.vchan("%d" % x, context, cda.PY_CXDTYPE_DOUBLE, 1000000))

for x in chans:
    x.valueMeasured.connect(printval)

t1 = time.time()

cda.py_sl_main_loop()
