include 'imports.pxi'

include 'scheduler.pxi'
include 'signal.pxi'
include 'timer.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='sl'

include 'cda_common.pxi'

include 'gw.pxi'
__all__ += ['PassGW']

# add cx scheduler specific simbols
__all__ += ['main_loop', 'break_', 'Timer', 'Signal']