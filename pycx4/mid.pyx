

from pycda cimport *

import numpy as np
from numpy.polynomial.polynomial import *




class middleChan(object):
    def __init__(self, source_name, middle_name, srclim=None):
        self.source_name = source_name
        self.middle_name = middle_name
        self.srclim = srclim  # limits [min,max]

        self.source_chan = sdchan(source_name)
        self.source_chan.valueChanged.connect(self.source_cb)
        self.middle_chan = sdchan(middle_name)
        self.middle_chan.valueChanged.connect(self.middle_cb)

        self.src_changing = False
        self.mid_changing = False

        self.starting = True

    def source_cb(self, chan, value):
        if self.starting:
            self.starting = False
        if self.mid_changing:
            self.mid_changing = False
            return
        self.middle_chan.setValue(self.src2mid(value))
        self.src_changing = True

    def middle_cb(self, chan, value):
        if self.starting:
            self.starting = False
            return
        if self.src_changing:
            self.src_changing = False
            return
        srcval = self.mid2src(value)
        if self.srclim is not None:
            if srcval < self.srclim[0] and self.srclim[0] is not None:
                self.middle_chan.setValue(self.src2mid(self.srclim[0]))
                self.source_chan.setValue(self.srclim[0])
                return
            if srcval > self.srclim[1] and self.srclim[1] is not None:
                self.middle_chan.setValue(self.src2mid(self.srclim[1]))
                self.source_chan.setValue(self.srclim[1])
                return
        self.source_chan.setValue(srcval)
        self.mid_changing = True

    def src2mid(self, src_val):
        return src_val

    def mid2src(self, mid_val):
        return mid_val


class middleChanPoly(middleChan):
    def __init__(self, source_name, middle_name, srclim, s2m, m2s):
        super(middleChanPoly, self).__init__(source_name, middle_name, srclim)
        self.s2m = s2m
        self.m2s = m2s

    def src2mid(self, src_val):
        mid_val = polyval(src_val, self.s2m)
        return mid_val

    def mid2src(self, mid_val):
        src_val = polyval(mid_val, self.m2s)
        return src_val


class middleChanRO(object):
    def __init__(self, source_name, middle_name):
        self.source_name = source_name
        self.middle_name = middle_name

        self.source_chan = cxchan(source_name)
        self.source_chan.valueChanged.connect(self.source_cb)
        self.middle_chan = cxchan(middle_name)

    def source_cb(self, chan, value):
        self.middle_chan.setValue(self.src2mid(value))

    def src2mid(self, src_val):
        return src_val


class middleChanPolyRO(middleChanRO):
    def __init__(self, source_name, middle_name, s2m):
        super(middleChanPolyRO, self).__init__(source_name, middle_name)
        self.s2m = s2m  #i2f coefs array

    def src2mid(self, src_val):
        mid_val = polyval(src_val, self.s2m)
        return mid_val


class middleChanEpics:
    def __init__(self, source_name, middle_name):
        self.source_name = source_name
        self.middle_name = middle_name
        self.src_changing = False
        self.mid_changing = False
        self.starting = False

        self.source_chan = camonitor(source_name, self.source_cb)
        self.middle_chan = cxchan(middle_name)
        self.middle_chan.valueChanged.connect(self.middle_cb)

    def source_cb(self, value):
        if self.starting:
            self.starting = False
        if self.mid_changing:
            self.mid_changing = False
            return
        self.middle_chan.setValue(self.src2mid(value))
        self.src_changing = True

    def middle_cb(self, chan, value):
        if self.starting:
            return
        if self.src_changing:
            self.src_changing = False
            return
        caput(self.source_name, self.mid2src(value))
        self.mid_changing = True

    def src2mid(self, src_val):
        return src_val

    def mid2src(self, mid_val):
        return mid_val
