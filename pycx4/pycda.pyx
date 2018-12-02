include 'imports.pxi'

include 'scheduler.pxi'
include 'Signal.pxi'
include 'Timer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='sl'

include 'cda_common.pxi'

# add cx scheduler specific simbols
__all__ += ['main_loop', 'break_', 'Timer', 'Signal']