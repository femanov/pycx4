
from cx4.cda cimport *
from libc.stdlib cimport realloc, free, malloc
from libc.string cimport memmove


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
# textual include of user level classes
include 'pycdauser.pxi'

