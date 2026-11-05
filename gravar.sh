#!/bin/sh
# screenrecord.sh - grava a tela inteira (X11) no OpenBSD com ffmpeg.
#
# Uso:
#   screenrecord.sh          inicia a gravacao (sem audio)
#   screenrecord.sh -a       inicia com audio do microfone (sndio)
#   screenrecord.sh          (de novo) para a gravacao em andamento
#   screenrecord.sh -h       ajuda
#
# Requisitos: doas pkg_add ffmpeg ; sessao X11 (XFCE, etc.)
# Audio: doas sysctl kern.audio.record=1  (vem desligado por padrao)
#        para persistir: echo kern.audio.record=1 >> /etc/sysctl.conf
#
# A gravacao usa mkv porque o arquivo continua valido mesmo se o ffmpeg
# for interrompido. Para converter depois: ffmpeg -i in.mkv -c copy out.mp4

set -u

OUTDIR="${SCREENRECORD_DIR:-$HOME/Videos}"
PIDFILE="${TMPDIR:-/tmp}/screenrecord-$(id -u).pid"
FPS="${SCREENRECORD_FPS:-30}"
CRF="${SCREENRECORD_CRF:-23}"
AUDIO=0

msg() { printf '%s\n' "$*" >&2; }

usage() {
	sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
	exit 0
}

while getopts 'ah' opt; do
	case "$opt" in
	a) AUDIO=1 ;;
	h) usage ;;
	*) usage ;;
	esac
done

# Se ja existe gravacao, para.
if [ -f "$PIDFILE" ]; then
	pid=$(cat "$PIDFILE")
	if kill -0 "$pid" 2>/dev/null; then
		kill -INT "$pid"
		rm -f "$PIDFILE"
		msg "Gravacao parada. Arquivos em: $OUTDIR"
		exit 0
	fi
	rm -f "$PIDFILE"
fi

command -v ffmpeg >/dev/null 2>&1 || {
	msg "ffmpeg nao encontrado. Instale com: doas pkg_add ffmpeg"
	exit 1
}

[ -n "${DISPLAY:-}" ] || {
	msg "DISPLAY vazio: rode dentro de uma sessao X11."
	exit 1
}

size=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ {print $2; exit}')
[ -n "$size" ] || {
	msg "Nao consegui ler o tamanho da tela (xdpyinfo)."
	exit 1
}

mkdir -p "$OUTDIR"
out="$OUTDIR/screenrecord-$(date '+%Y-%m-%d_%H-%M-%S').mkv"

if [ "$AUDIO" -eq 1 ]; then
	if [ "$(sysctl -n kern.audio.record 2>/dev/null)" != "1" ]; then
		msg "Gravacao de audio desligada. Rode: doas sysctl kern.audio.record=1"
		exit 1
	fi
	ffmpeg -y -loglevel error \
		-f x11grab -framerate "$FPS" -video_size "$size" -i "$DISPLAY" \
		-f sndio -i default \
		-c:v libx264 -preset veryfast -crf "$CRF" -pix_fmt yuv420p \
		-c:a flac "$out" </dev/null >/dev/null 2>&1 &
else
	ffmpeg -y -loglevel error \
		-f x11grab -framerate "$FPS" -video_size "$size" -i "$DISPLAY" \
		-c:v libx264 -preset veryfast -crf "$CRF" -pix_fmt yuv420p \
		"$out" </dev/null >/dev/null 2>&1 &
fi

pid=$!
echo "$pid" >"$PIDFILE"
sleep 1

if kill -0 "$pid" 2>/dev/null; then
	msg "Gravando ${size} a ${FPS} fps -> $out"
	msg "Rode de novo para parar."
else
	rm -f "$PIDFILE"
	msg "Falhou ao iniciar o ffmpeg. Teste o comando manualmente para ver o erro."
	exit 1
fi
