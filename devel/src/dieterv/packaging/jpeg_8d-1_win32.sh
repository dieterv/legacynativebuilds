# This is a shell script that calls functions and scripts from
# tml@iki.fi's personal work environment. It is not expected to be
# usable unmodified by others, and is included only for reference.

MOD=jpeg
VER=8d
REV=1
ARCH=win32

THIS=${MOD}_${VER}-${REV}_${ARCH}

RUNZIP=${MOD}_${VER}-${REV}_${ARCH}.zip
DEVZIP=${MOD}-dev_${VER}-${REV}_${ARCH}.zip

HEX=`echo $THIS | md5sum | cut -d' ' -f1`
TARGET=/devel/target/$HEX

usedev
usewinsdk52

(

set -x

CC='gcc -mtune=pentium3 -mthreads' \
CFLAGS=-O2 \
./configure \
--disable-static \
--prefix=$TARGET &&

make install &&

rm -f /tmp/$RUNZIP /tmp/$DEVZIP &&

cd $TARGET &&
zip /tmp/$RUNZIP bin/libjpeg-8.dll &&
zip /tmp/$DEVZIP bin/*.exe &&
zip /tmp/$DEVZIP lib/*.dll.a &&
zip -r -D /tmp/$DEVZIP include share

) 2>&1 | tee /devel/src/dieterv/packaging/$THIS.log

(cd /devel && zip /tmp/$DEVZIP src/dieterv/packaging/$THIS.{sh,log}) &&
manifestify /tmp/$RUNZIP /tmp/$DEVZIP
