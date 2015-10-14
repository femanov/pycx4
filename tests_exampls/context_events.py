#!/usr/bin/env python

import pycx4.pycda as cda

import signal
signal.signal(signal.SIGINT, signal.SIG_DFL)


def print_event(cont):
    print(cont)


context = cda.cda_context("localhost:1.NAME")
context.serverCycle.connect(print_event)
context.enable_serverCycle()

# no chans - no context events :-)
c = cda.sdchan("%d" % 0, context)

cda.py_sl_main_loop()
