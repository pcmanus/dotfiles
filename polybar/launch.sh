#!/usr/bin/env sh

# number of monitors connected
monitors=`xrandr | grep " connected " | wc -l`
# will be 1 when on my laptop (called x1), 0 otherwise
laptop=`uname -a | grep "x1" | wc -l`

# Terminate already running instances
killall -q polybar

if [ $laptop -eq 0 ]
then
    if [ $monitors -eq 1 ]
    then
        polybar desktop &
    else
        polybar desktop-left &
        polybar desktop-right &
    fi
else
    if [ $monitors -eq 1 ]
    then
        polybar laptop-one &
    else
        polybar laptop-left &
        polybar laptop-right &
    fi
fi

