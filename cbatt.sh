#!/bin/sh
# cbatt - text printout for battery usage/time for text-based status bars;
# useful for window managers like awesome, wmii, xmonad etc.
#
# 24.05.2011 - Stefan Behte

echo -n '['

if [ "$1" = "color" ]
then
	echo -n '<span color="green">'
fi

grep -q 1 /sys/class/power_supply/AC/online && echo -n "+"

acpiout=$(acpi)
if [ -n "$(echo -n ${acpiout} | grep 'charging at zero rate - will never fully charge.')" ]
then
	echo -n "${acpiout}" | awk '{print $4, $5}' | awk -F',' '{print $1}' | sed -e 's@,@/@g' -e 's@ @@g' | tr -d '\n'
	echo -n '/charging at zero rate'

elif [ -n "$(echo -n ${acpiout} | grep 'Unknown, ')" ]
then
	echo -n "${acpiout}" | awk '{print $4, $5}' | sed -e 's@,@/@g' -e 's@ @@g' | tr -d '\n'
	echo -n '/unknown'

elif [ -n "$(echo -n ${acpiout} | grep 'Full, 100%')" ]
then
	echo -n "100%"
else
	echo -n "${acpiout}" | awk '{print $4, $5}' | sed 's@, @/@g' | awk -F: '{print $1 ":" $2}' | tr -d '\n'
fi

if [ "$1" = "color" ]
then
	echo -n '</span>'
fi

echo -n ']'

