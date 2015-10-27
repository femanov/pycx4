#!/bin/sh

set -e

CXDIR=$HOME/cx

make -C $CXDIR/cx/src create-exports exports
make -C $CXDIR/cx/src/lib/Qcxscheduler TOPDIR=$CXDIR/cx/src
make -C $CXDIR/cx/src/lib/4PyQt TOPDIR=$CXDIR/cx/src
make -C $CXDIR/4cx/src
make -C $CXDIR/v2hw TOPDIR=$CXDIR/cx/src CPU_X86_COMPAT=no
make -C $CXDIR/qult TOPDIR=$CXDIR/cx/src V2HDIR=$CXDIR/v2hw
