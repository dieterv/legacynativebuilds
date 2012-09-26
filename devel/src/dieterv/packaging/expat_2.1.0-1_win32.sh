# This is a shell script that calls functions and scripts from
# tml@iki.fi's personal work environment. It is not expected to be
# usable unmodified by others, and is included only for reference.

MOD=expat
VER=2.1.0
REV=1
ARCH=win32

THIS=${MOD}_${VER}-${REV}_${ARCH}

RUNZIP=${MOD}_${VER}-${REV}_${ARCH}.zip
DEVZIP=${MOD}-dev_${VER}-${REV}_${ARCH}.zip

# We use a string of hex digits to make it more evident that it is
# just a hash value and not supposed to be relevant at end-user
# machines.
HEX=`echo $THIS | md5sum | cut -d' ' -f1`
TARGET=/devel/target/$HEX

usestable
usewinsdk52

(

set -x

# Don't let libtool do its relinking dance. Don't know how relevant
# this is, but it doesn't hurt anyway.

sed -e 's/need_relink=yes/need_relink=no # no way --tml/' <conftools/ltmain.sh >conftools/ltmain.temp && mv conftools/ltmain.temp conftools/ltmain.sh &&

patch -p0 <<\EOF &&
--- Makefile.in
+++ Makefile.in
@@ -79,7 +79,7 @@
 
 install: xmlwf/xmlwf@EXEEXT@ installlib
 	$(mkinstalldirs) $(DESTDIR)$(bindir) $(DESTDIR)$(man1dir)
-	$(LIBTOOL) --mode=install $(INSTALL_PROGRAM) xmlwf/xmlwf@EXEEXT@ $(DESTDIR)$(bindir)/xmlwf
+	$(LIBTOOL) --mode=install $(INSTALL_PROGRAM) xmlwf/xmlwf@EXEEXT@ $(DESTDIR)$(bindir)/xmlwf@EXEEXT@
 	$(INSTALL_DATA) $(MANFILE) $(DESTDIR)$(man1dir)
 
 installlib: $(LIBRARY) $(APIHEADER) expat.pc
@@ -121,7 +121,7 @@
 COMPILE = $(CC) $(INCLUDES) $(CFLAGS) $(DEFS) $(CPPFLAGS)
 CXXCOMPILE = $(CXX) $(INCLUDES) $(CXXFLAGS) $(DEFS) $(CPPFLAGS)
 LTCOMPILE = $(LIBTOOL) $(LTFLAGS) --mode=compile $(COMPILE)
-LINK_LIB = $(LIBTOOL) $(LTFLAGS) --mode=link $(COMPILE) -no-undefined $(VSNFLAG) -rpath $(libdir) $(LDFLAGS) -o $@
+LINK_LIB = $(LIBTOOL) $(LTFLAGS) --mode=link $(COMPILE) -no-undefined $(VSNFLAG) -rpath $(libdir) $(LDFLAGS) -o $@ -export-symbols lib/libexpat.def
 LINK_EXE = $(LIBTOOL) $(LTFLAGS) --mode=link $(COMPILE) $(LDFLAGS) -o $@
 LINK_CXX_EXE = $(LIBTOOL) $(LTFLAGS) --mode=link $(CXXCOMPILE) $(LDFLAGS) -o $@
 
EOF

CC='gcc -mthreads' LDFLAGS='-Wl,--enable-auto-image-base' CFLAGS=-O2 ./configure --prefix=$TARGET --disable-static &&

make install &&

cp lib/libexpat.def $TARGET/lib &&
(cd $TARGET/lib && lib.exe -machine:IX86 -def:libexpat.def -out:expat.lib) &&

rm -f /tmp/$RUNZIP /tmp/$DEVZIP &&

(cd $TARGET &&
zip /tmp/$RUNZIP bin/libexpat-1.dll &&
zip /tmp/$DEVZIP bin/xmlwf.exe &&
zip -r -D /tmp/$DEVZIP include &&
zip /tmp/$DEVZIP lib/{libexpat.dll.a,libexpat.def,expat.lib} &&
zip -r -D /tmp/$DEVZIP share
)

) 2>&1 | tee /devel/src/dieterv/packaging/$THIS.log

(cd /devel && zip /tmp/$DEVZIP src/dieterv/packaging/$THIS.{sh,log}) &&
manifestify /tmp/$RUNZIP /tmp/$DEVZIP
