#!/bin/sh

setxkbmap -option caps:escape
setxkbmap -option compose:ralt
xset r rate 200 50

# will be 1 when my 2 monitors are connected, 0 otherwise
multihead=`xrandr | grep " connected " | grep "DP1-2" | wc -l`

if [ $multihead -eq 1 ]
then
    $HOME/.bin/godualscreen.sh
else
    $HOME/.bin/gosinglescreen.sh
fi

feh --bg-scale $HOME/.wallpaper.png

$HOME/.config/polybar/launch.sh
