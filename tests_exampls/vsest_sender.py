#!/usr/bin/env python

import signal
import pycx4.pycda as cda

signal.signal(signal.SIGINT, signal.SIG_DFL)

nchans = 50

def printval(chan):
    chan.setValue(chan.val+1)


context = cda.cda_context("localhost:2.NAME")

chans = []

for x in range(nchans):
    chans.append(cda.vchan("%d" % x, context, cda.PY_CXDTYPE_DOUBLE, 1000))

for x in chans:
    x.valueMeasured.connect(printval)

cda.py_sl_main_loop()
