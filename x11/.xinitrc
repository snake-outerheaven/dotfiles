#!/bin/sh
# ~/.xinitrc - dwm Gruvbox no OpenBSD (iniciar com: startx)

xrdb -merge ~/.Xresources
xsetroot -solid "#282828"

# barra: volume, bateria e data (script em ~/.local/bin/dwm-status)
~/.local/bin/dwm-status &

exec dwm
