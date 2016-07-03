include 'imports.pxi'

include 'scheduler.pxi'
include 'Signal.pxi'
include 'Timer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='sl'

# textual include of basic level cda classes
include 'cxdtype.pxi'
include 'rflags.pxi'

include 'event.pxi'

include 'cdaobject.pxi'

include 'context.pxi'

cdef Context default_context=Context()

include 'basechan.pxi'

include 'dchan.pxi'
include 'chan.pxi'
include 'vchan.pxi'
include 'strchan.pxi'