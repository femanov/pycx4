
cdef class ChanFactory:
    cdef:
        dict single_chans, vector_chans

    def __init__(self):
        self.single_chans = {
            'double': DChan,
            'int': IChan,
            'int32': IChan
        }
        self.vector_chans = {
            'str': StrChan,
        }

    def create_chan(self, name, dtype, dsize, **kwargs):
        if dtype not in cx_dtype_map:
            return None
        if dsize == 1:
            if dtype in self.single_chans:
                return self.single_chans[dtype](name, **kwargs)
            else:
                return Chan(name, cx_dtype_map[dtype])
        elif dtype in self.vector_chans:
            return self.vector_chans[dtype](name, dsize)
        return VChan(name, cx_dtype_map[dtype], dsize, **kwargs)

cfactory = ChanFactory()

