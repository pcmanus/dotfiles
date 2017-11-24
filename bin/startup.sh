#!/bin/sh

setxkbmap -option caps:escape
xset r rate 200 50

# will be 1 when my 2 monitors are connected, 0 otherwise
multihead=`xrandr | grep " connected " | grep "DP2-2" | wc -l`

if [ $multihead -eq 1 ]
then
    $HOME/.bin/godualscreen.sh
else

feh --bg-scale $HOME/.wallpaper.png
