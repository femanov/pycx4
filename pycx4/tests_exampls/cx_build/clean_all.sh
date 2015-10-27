#!/bin/sh


CXDIR=$HOME/cx

make -kC $CXDIR/cx/src clean maintainer-clean
make -kC $CXDIR/cx/src/lib/Qcxscheduler TOPDIR=$CXDIR/cx/src clean maintainer-clean
make -kC $CXDIR/cx/src/lib/4PyQt TOPDIR=$CXDIR/cx/src clean maintainer-clean
make -kC $CXDIR/4cx/src clean maintainer-clean
make -kC $CXDIR/v2hw TOPDIR=$CXDIR/cx/src clean maintainer-clean
make -kC $CXDIR/qult TOPDIR=$CXDIR/cx/src V2HDIR=$CXDIR/v2hw clean maintainer-clean
