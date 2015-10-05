#!/bin/sh
wgetpath=`which wget`
sshpath=`which ssh`
routerlogin='neo'
routerhostip='x.x.x.x'
routerfwdport='2222'
openwrtsshport='22'
urlfile='http://www.domain.com/tmp/file'
COMMAND="$sshpath -f -N -R $routerfwdport:$routerhostip:$openwrtsshport $routerlogin@$routerhostip"
$wgetpath -O/dev/null -q $urlfile && exist=1 || exist=0
if [ "$exist" = "1" ]
   then pgrep -f -x "$COMMAND" > /dev/null 2>&1 || $COMMAND
   else pgrep -f -x "$COMMAND" > /dev/null 2>&1 && pkill -f -x "$COMMAND" || exit 0
fi
