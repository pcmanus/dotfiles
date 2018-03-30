#!/bin/sh

xrandr --output DP1-1 --auto --primary && xrandr --output DP1-2 --right-of DP1-1 --auto && xrandr --output eDP1 --off
