

include 'scheduler.pxi'

# conpile-time define for contitional compilation
DEF SIGNAL_IMPL='sl'

# textual include of basic level cda classes
include 'pycdabase.pxi'
# textual include of user level classes
include 'pycdauser.pxi'

