#!/bin/sh
# cbatt - text printout for battery usage/time for text-based status bars;
# useful for window managers like awesome, wmii, xmonad etc.
#
# 24.05.2011 - Stefan Behte

echo -n '['

grep -q 1 /sys/class/power_supply/AC/online && echo -n "+"
acpi | awk '{print $4, $5}' | sed 's@, @/@g' | awk -F: '{print $1 ":" $2}' | tr -d '\n'

echo -n ']'

