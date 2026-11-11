#!/bin/sh
# ~/.xinitrc - dwm amarelo Gruvbox no OpenBSD (iniciar com: startx)

xrdb -merge ~/.Xresources
xsetroot -solid "#282828"

# barra de status: data, bateria (apm) e volume (sndioctl)
while true; do
	bat=$(apm -l 2>/dev/null)
	vol=$(sndioctl -n output.level 2>/dev/null | awk '{ printf "%d", $1 * 100 }')
	xsetroot -name " $(date '+%d/%m %H:%M') | bat ${bat}% | vol ${vol}% "
	sleep 30
done &

exec dwm
