#!/bin/sh
# Barra do chadwm adaptada ao OpenBSD (apm, sysctl, sndioctl, ifconfig)
# ^c$cor^ = cor do texto, ^b$cor^ = cor de fundo, ^d^ = volta ao padrao

. ~/.config/chadwm/scripts/bar_themes/gruvbox

cpu() {
	val=$(sysctl -n vm.loadavg 2>/dev/null | cut -d' ' -f1)
	printf "^c$black^ ^b$green^ CPU ^c$white^^b$grey^ %s ^b$black^" "${val:-?}"
}

battery() {
	val=$(apm -l 2>/dev/null)
	printf "^c$black^ ^b$red^ BAT ^c$white^^b$grey^ %s%% ^b$black^" "${val:-?}"
}

volume() {
	val=$(sndioctl -n output.level 2>/dev/null | awk '{ printf "%d", $1 * 100 }')
	printf "^c$black^ ^b$aqua^ VOL ^c$white^^b$grey^ %s%% ^b$black^" "${val:-?}"
}

wlan() {
	if ifconfig 2>/dev/null | grep -q 'status: active'; then
		printf "^c$black^ ^b$blue^ NET ^c$white^^b$grey^ on ^b$black^"
	else
		printf "^c$black^ ^b$blue^ NET ^c$white^^b$grey^ off ^b$black^"
	fi
}

clock() {
	printf "^c$black^ ^b$yellow^ %s ^b$black^" "$(date '+%d/%m %H:%M')"
}

while true; do
	xsetroot -name "$(cpu) $(battery) $(volume) $(wlan) $(clock)"
	sleep 5
done
