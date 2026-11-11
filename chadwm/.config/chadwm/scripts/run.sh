#!/bin/sh
# Autostart do chadwm (chamado pelo ~/.xinitrc)

xrdb -merge ~/.Xresources
xsetroot -solid "#282828"
xset r rate 250 40 &

sh ~/.config/chadwm/scripts/bar.sh &

# reinicia o chadwm se ele sair com erro; sai de vez com Super+Ctrl+q
while type chadwm >/dev/null 2>&1; do chadwm && continue || break; done
