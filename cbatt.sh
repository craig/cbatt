#!/bin/sh
# cbatt - text printout for battery usage/time for text-based status bars;
# useful for window managers like awesome, wmii, xmonad etc.
#
# 24.05.2011 - Stefan Behte

echo -n '['

if [ "$1" = "color" ]
then
## first check for charging, then specify color
#	echo -n '<span color="red">'
	COLOR=true
else
	COLOR=false
fi

case `uname -s` in
	Linux)
		if grep -q 1 /sys/class/power_supply/AC/online
		then
			CHARGING=true
		else
			CHARGING=false
		fi
		;;
	FreeBSD)
		# beware of the ^V^I !
		if acpiconf -i 0 | egrep -q 'State:[\ \	]*discharging'
		then
			CHARGING=false
		else
			CHARGING=true
		fi
		;;
esac

if $COLOR
then
	if $CHARGING; then
		echo -n '<span color="green">'
	else
		echo -n '<span color="red">'
	fi
fi

$CHARGING && echo -n "+"

case `uname -s` in
	Linux)
		acpiout=`acpi`
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
	;;
	FreeBSD)
		acpiout=`acpiconf -i 0`
		# charging at zero rate
	
		# unknown
		if echo "${acpiout}" | egrep -q '^Remaining time:[	]*unknown'
		then
			echo -n "${acpiout}" | sed -e '/^Remaining capacity/!d' \
				-e 's/.*:[	]*//' | tr -d '\n'
			echo -n '/unknown'
		# full
		elif echo "${acpiout}" | egrep -q '^Remaining capacity:[  ]*100%'
		then
			echo -n '100%'
		# anything else
		else
			echo -n "${acpiout}" | sed -e '/^Remaining capacity/!d' \
				-e 's/.*:[	]*//' | tr -d '\n'
			echo -n "${acpiout}" | sed -e '/^Remaining time/!d' \
				-e 's@Remaining time:[	]*@/@' | tr -d '\n'
		fi
	;;
esac

if $COLOR
then
	echo -n '</span>'
fi

echo -n ']'
