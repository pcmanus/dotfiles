#!/usr/bin/env sh

# will be 1 when my 2 monitors are connected, 0 otherwise
multihead=`xrandr | grep " connected " | grep "DP2-2" | wc -l`
# will be 1 when on my laptop (called carbon), 0 otherwise
laptop=`uname -a | grep "carbon" | wc -l`

# Terminate already running instances
killall -q polybar

if [ $laptop -eq 0 ]
then
    polybar desktop &
else
    if [ $multihead -eq 0 ]
    then
        polybar laptop-one &
    else
        polybar laptop-left &
        polybar laptop-right &
    fi
fi

