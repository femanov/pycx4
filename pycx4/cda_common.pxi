
# textual include of basic level cda classes
include 'cxdtype.pxi'
include 'rflags.pxi'

include 'event.pxi'

include 'cdaobject.pxi'

include 'context.pxi'

cdef Context default_context=Context()

include 'basechan.pxi'

include 'dchan.pxi'
include 'ichan.pxi'
include 'chan.pxi'
include 'vchan.pxi'
include 'strchan.pxi'
include 'chan_factory.pxi'

include 'cda_all.pxi'
