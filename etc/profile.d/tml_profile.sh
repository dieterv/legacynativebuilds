# Copyright (c) 2011 Tor Lillqvist. This script is licensed under the
# MIT/X11 license. See http://www.opensource.org/licenses/mit-license

export PKG_CONFIG=/opt/local/bin/pkg-config.sh

function prepend_dir_to_path() {
  [ -d "$2" ] && {
      local expr="export $1='$2'"
      local oldval="`eval echo '$'$1`"
      test -z "$oldval" || expr="$expr:'""$oldval""'"
      # echo $expr
      eval $expr
  }
}

function prepend_option_dir_to_var() {
  [ -d "$3" ] && {
      local expr="export $1='-I $3'"
      local oldval="`eval echo '$'$1`"
      test -z "$oldval" || expr="$expr' ""$oldval""'"
      # echo $expr
      eval $expr
  }
}

PATH=/bin:$PATH
prepend_dir_to_path PATH /opt/local/bin

BASEPATH=$PATH

export LT_NO_LA_FILES=y

export ACLOCAL_FLAGS="-I /usr/share/aclocal"

export INTLTOOL_PERL=/opt/perl/bin/perl
export INTLTOOL_ICONV=/opt/gnu/bin/iconv

export CVS_RSH=/opt/misc/bin/plink
export SVN_SSH=/opt/misc/bin/plink
export GIT_SSH=/opt/misc/bin/plink.exe

# This seems to work with Visual Studio:
export _NT_SYMBOL_PATH='SRV*c:\tmp\symbols*http://msdl.microsoft.com/download/symbols'

function usebase() {
  PATH="$BASEPATH"
  export PKG_CONFIG_PATH=/dummy
  export ACLOCAL_FLAGS="-I /usr/share/aclocal"
  unset LIB
  unset INCLUDE
}

function usemingw32() {
  usebase
  prepend_dir_to_path PATH /mingw/bin
}

function usemingw() {
  usemingw32
}

function usedev() {
  usemingw
  prepend_dir_to_path PATH /opt/misc/bin
}

function usestable() {
  usedev
  prepend_dir_to_path PATH /devel/target/stable/bin

  prepend_dir_to_path PKG_CONFIG_PATH /opt/misc/lib/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /opt/freetype/lib/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/stable/share/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/stable/lib/pkgconfig

  ACLOCAL_FLAGS=""
  prepend_option_dir_to_var ACLOCAL_FLAGS -I /opt/misc/share/aclocal

  prepend_option_dir_to_var ACLOCAL_FLAGS -I /devel/target/stable/share/aclocal
}

function usehead() {
  usestable

  prepend_dir_to_path PATH /devel/target/HEAD/bin

  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/HEAD/share/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/HEAD/lib/pkgconfig

  prepend_option_dir_to_var ACLOCAL_FLAGS -I /devel/target/HEAD/share/aclocal
}

function usemingw64() {
  prepend_dir_to_path PATH /opt/mingw64/bin
}

function usemsvs6() {
  PATH="/opt/MSVS6/VC98/Bin:/opt/MSVS6/Common/MSDev98/Bin:/opt/MSVS6/Common/Tools:$PATH"
  export INCLUDE='c:\opt\MSVS6\VC98\Include'
  export LIB='c:\opt\MSVS6\VC98\Lib'
}

function usemsvs7() {
  PATH="/opt/MSVS7/Vc7/bin:/opt/MSVS7/Common7/IDE:/opt/MSVS7/SDK/v1.1/bin:$PATH"
  export INCLUDE='c:\opt\MSVS7\Vc7\include;c:\opt\psdk\Include'
  export LIB='c:\opt\MSVS7\Vc7\lib;\opt\psdk\Lib'
}

function usemsvs9() {
  prepend_dir_to_path PATH /opt/MSVS9/VC/bin
  prepend_dir_to_path PATH /opt/MSVS9/Common7/IDE
  prepend_dir_to_path PATH /opt/MSVS9/Common7/Tools
  prepend_dir_to_path PATH /opt/winsdk7/Bin

  export INCLUDE='c:\opt\MSVS9\VC\include;c:\Program Files\Microsoft SDKs\Windows\v7.0\Include'
  export LIB='c:\opt\MSVS9\VC\lib;c:\Program Files\Microsoft SDKs\Windows\v7.0\Lib'
}

function usemsvs9x64() {
  prepend_dir_to_path PATH /opt/MSVS9/VC/bin
  prepend_dir_to_path PATH /opt/MSVS9/VC/bin/amd64
  prepend_dir_to_path PATH /opt/MSVS9/Common7/IDE
  prepend_dir_to_path PATH /opt/MSVS9/Common7/Tools
  prepend_dir_to_path PATH /opt/winsdk7/Bin
  prepend_dir_to_path PATH /opt/winsdk7/Bin/x64

  export INCLUDE='c:\opt\MSVS9\VC\include;c:\Program Files\Microsoft SDKs\Windows\v7.0\Include'
  export LIB='c:\opt\MSVS9\VC\lib\amd64;c:\Program Files\Microsoft SDKs\Windows\v7.0\Lib\x64'
}

function usepython() {
  PATH="/opt/python26:$PATH"
}

function usegimp26() {
  prepend_dir_to_path PATH /devel/target/gegl/bin
  prepend_dir_to_path PATH /devel/target/gimp/2.6/bin

  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/gegl/lib/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/gimp/2.6/lib/pkgconfig
}

function usegimphead() {
  prepend_dir_to_path PATH /devel/target/gegl/bin
  prepend_dir_to_path PATH /devel/target/gimp/HEAD/bin

  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/gegl/lib/pkgconfig
  prepend_dir_to_path PKG_CONFIG_PATH /devel/target/gimp/HEAD/lib/pkgconfig
}

function usedistarch() {
  local arch=$1
  [ -d /devel/dist/win${arch} ] || { echo No such arch '"'win${arch}'"' >&2; exit 1; }
  usemingw${arch}
  while read module version morestuff; do
    if [ "#" = $module ]; then
      :
    else
      D=/devel/dist/win${arch}/$module-$version
      [ -d $D/bin ] && PATH=$D/bin:$PATH
      [ -d $D/lib/libglade/2.0 ] && LIBGLADE_MODULE_PATH=$D/lib/libglade/2.0:$LIBGLADE_MODULE_PATH
      if [ -d $D/lib/pkgconfig ] ; then
          PKG_CONFIG_PATH=$D/lib/pkgconfig:$PKG_CONFIG_PATH
      elif [ -d $D/share/pkgconfig ] ; then
          PKG_CONFIG_PATH=$D/share/pkgconfig:$PKG_CONFIG_PATH
      fi
      [ -d $D/lib/pkgconfig ] && PKG_CONFIG_PATH=$D/lib/pkgconfig:$PKG_CONFIG_PATH
      [ -d $D/share/aclocal ] && ACLOCAL_FLAGS="-I $D/share/aclocal $ACLOCAL_FLAGS"
      eval $morestuff
    fi
  done < /devel/dist/win${arch}/LATEST
}

function usedist() {
  usedistarch 32
}

function usedist32() {
  usedistarch 32
}

function usedist64() {
  usedistarch 64
}
