#!/usr/bin/env bash
# Configura linguagens de sistemas + Java (compiladores/runtimes + language servers)
# no Fedora 44: C/C++, Rust, Go, Assembly e Java.
#
# Uso: ./setup-languages-fedora.sh [--only c,rust,go,java,asm] [--skip ...]
set -euo pipefail

ALL=(c rust go java asm)
ONLY=()
SKIP=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only) IFS=, read -ra ONLY <<<"$2"; shift 2 ;;
    --skip) IFS=, read -ra SKIP <<<"$2"; shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Argumento desconhecido: $1" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

enabled() {
  local n="$1" x
  for x in "${SKIP[@]}"; do [[ "$x" == "$n" ]] && return 1; done
  [[ ${#ONLY[@]} -eq 0 ]] && return 0
  for x in "${ONLY[@]}"; do [[ "$x" == "$n" ]] && return 0; done
  return 1
}

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  [[ "${ID:-}" == "fedora" ]] || { echo "Este script é para Fedora (detectado: ${ID:-?})." >&2; exit 1; }
  [[ "${VERSION_ID:-}" == "44" ]] || warn "Testado para Fedora 44 (detectado: ${VERSION_ID:-?})."
fi

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

PROFILE_SNIPPET="$HOME/.config/dotfiles-languages.sh"
FISH_SNIPPET="$HOME/.config/fish/conf.d/dotfiles-languages.fish"
mkdir -p "$(dirname "$PROFILE_SNIPPET")"
touch "$PROFILE_SNIPPET"
add_env() { grep -qxF -- "$1" "$PROFILE_SNIPPET" || echo "$1" >>"$PROFILE_SNIPPET"; }
add_fish() {
  mkdir -p "$(dirname "$FISH_SNIPPET")"
  touch "$FISH_SNIPPET"
  grep -qxF -- "$1" "$FISH_SNIPPET" || echo "$1" >>"$FISH_SNIPPET"
}

dnf_install() { $SUDO dnf install -y --setopt=install_weak_deps=False "$@"; }

log "Atualizando metadados do dnf"
$SUDO dnf makecache
dnf_install ca-certificates curl git gcc gcc-c++ make pkgconf-pkg-config unzip xz tar

# ---------- C / C++ ----------
if enabled c; then
  log "C/C++: gcc, g++, clang, clangd, clang-format, cmake, gdb, make"
  dnf_install gcc gcc-c++ clang clang-tools-extra cmake ninja-build gdb make valgrind bear
fi

# ---------- Rust ----------
if enabled rust; then
  log "Rust: rustup + rust-analyzer"
  if ! have rustup && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  export PATH="$HOME/.cargo/bin:$PATH"
  rustup component add rust-analyzer clippy rustfmt
  add_env 'export PATH="$HOME/.cargo/bin:$PATH"'
  add_fish 'fish_add_path $HOME/.cargo/bin'
fi

# ---------- Go ----------
if enabled go; then
  log "Go + gopls"
  dnf_install golang
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$PATH"
  go install golang.org/x/tools/gopls@latest
  add_env 'export GOPATH="$HOME/go"'
  add_env 'export PATH="$GOPATH/bin:$PATH"'
  add_fish 'set -gx GOPATH $HOME/go'
  add_fish 'fish_add_path $GOPATH/bin'
fi

# ---------- Java ----------
if enabled java; then
  log "Java: OpenJDK (JDK padrão), maven, gradle"
  dnf_install java-latest-openjdk-devel maven gradle
  warn "Para eglot em java-mode, instale o jdtls manualmente (não há pacote no Fedora): https://github.com/eclipse-jdtls/eclipse.jdt.ls"
fi

# ---------- Assembly (asm-blin-it: nasm x86_64 e MIPS32) ----------
if enabled asm; then
  log "Assembly: nasm, binutils, glibc 32-bit, spim (MIPS)"
  dnf_install nasm binutils glibc-devel.i686 libgcc.i686 || warn "pacotes 32-bit falharam"
  dnf_install spim || warn "spim indisponível; use MARS/QtSpim para MIPS32"
fi

# ---------- Shell ----------
BASHRC="$HOME/.bashrc"
LINE='[ -r "$HOME/.config/dotfiles-languages.sh" ] && . "$HOME/.config/dotfiles-languages.sh"'
grep -qxF "$LINE" "$BASHRC" 2>/dev/null || echo "$LINE" >>"$BASHRC"

log "Pronto. Abra um novo shell (ou 'source ~/.bashrc') para carregar o PATH."
have fish && warn "fish: PATH configurado em $FISH_SNIPPET"
