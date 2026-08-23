#!/usr/bin/env bash
#
# gruvboxify.sh — converte uma imagem para a paleta de cores Gruvbox
# usando ImageMagick (-remap), muito mais rápido que soluções em
# Python puro (pixel a pixel).
#
# Uso:
#   ./gruvboxify.sh /caminho/absoluto/para/foto.jpg
#   ./gruvboxify.sh /caminho/absoluto/para/foto.jpg /pasta/de/saida/
#
# Requer: imagemagick (comando `convert`)

set -euo pipefail

# ---------- validação de argumentos ----------
if [[ $# -lt 1 ]]; then
    echo "Uso: $0 /caminho/absoluto/para/imagem [pasta_de_saida]" >&2
    exit 1
fi

INPUT="$1"
OUTDIR="${2:-}"

if [[ "$INPUT" != /* ]]; then
    echo "Erro: forneça um caminho absoluto (começando com /)." >&2
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Erro: arquivo não encontrado: $INPUT" >&2
    exit 1
fi

if ! command -v convert &>/dev/null; then
    echo "Erro: ImageMagick não encontrado. Instale com: sudo apt install imagemagick" >&2
    exit 1
fi

# ---------- monta a paleta gruvbox (22 cores oficiais) ----------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

PALETTE_TXT="$TMPDIR/gruvbox.txt"
PALETTE_PNG="$TMPDIR/gruvbox_palette.png"

COLORS=(
    "#282828" "#3c3836" "#504945" "#665c54" "#7c6f64" "#928374"
    "#ebdbb2" "#d5c4a1" "#bdae93" "#a89984"
    "#cc241d" "#98971a" "#d79921" "#458588" "#b16286" "#689d6a"
    "#fb4934" "#b8bb26" "#fabd2f" "#83a598" "#d3869b" "#8ec07c"
)

{
    echo "# ImageMagick pixel enumeration: ${#COLORS[@]},1,255,srgb"
    for i in "${!COLORS[@]}"; do
        hex="${COLORS[$i]}"
        r=$((16#${hex:1:2}))
        g=$((16#${hex:3:2}))
        b=$((16#${hex:5:2}))
        echo "${i},0: (${r},${g},${b}) ${hex}"
    done
} > "$PALETTE_TXT"

convert "$PALETTE_TXT" "$PALETTE_PNG"

# ---------- define caminho de saída ----------
FILENAME="$(basename "$INPUT")"
NAME="${FILENAME%.*}"
EXT="${FILENAME##*.}"

if [[ -n "$OUTDIR" ]]; then
    mkdir -p "$OUTDIR"
    OUTPUT="${OUTDIR%/}/${NAME}_gruvbox.${EXT}"
else
    DIR="$(dirname "$INPUT")"
    OUTPUT="${DIR}/${NAME}_gruvbox.${EXT}"
fi

# ---------- aplica a conversão ----------
convert "$INPUT" -dither FloydSteinberg -remap "$PALETTE_PNG" "$OUTPUT"

echo "✔ Imagem gruvboxificada salva em: $OUTPUT"
