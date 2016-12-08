#!/bin/sh

i="$1"
shift

echo -n "Testing \"$i\" ..."
if ! tail -n 1 "$i" | grep -q '^%$'  ; then
    echo " failed % check"
    echo "Fortune cookie file does not end in a single %"
    exit 1
fi
if egrep -q ".{81}" "$i" ; then
    echo " failed length check"
    echo "Fortune cookie file contains a line longer than 78 characters"
    exit 1
fi
if egrep -q "`printf "\\r"`" "$i" ; then
    echo " failed lack of carriage-return check"
    echo "Fortune cookie file contains a CR"
    exit 1
fi
if egrep -q "[ `printf "\\t"`]\$$" "$i" ; then
    echo " failed lack of trailing space check"
    echo "Fortune cookie file contains trailing whitespace"
    exit 1
fi
echo " passed "
exit 0
