#!/bin/sh
export PATH=/devel/dist/win32/glib-2.20.3-1/bin:$PATH
if /devel/dist/win32/`latest pkg-config`/bin/pkg-config "$@" > /dev/null 2>&1 ; then
   res=true
else
   res=false
fi
/devel/dist/win32/`latest pkg-config`/bin/pkg-config "$@" | tr -d \\r && $res
