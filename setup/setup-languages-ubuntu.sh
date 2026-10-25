#!/usr/bin/env bash
# Configura as linguagens (compiladores/runtimes + language servers) em Ubuntu.
# Derivado dos repos em github.com/snake-outerheaven (cpp-starter, rust-starter,
# python-nest, lua-tale, keep-going, coffee4code, chunky-ruby, php-starter,
# training-room, asm-blin-it, bash-ing-it, eloquent-journal, boxes, ...) e do
# ~/.emacs.d/init.el (eglot: clangd, pyright, typescript-language-server, lua-language-server,
# rust-analyzer, gopls; java-mode; Emacs Lisp).
#
# Uso: ./setup-languages.sh [--only c,python,node,rust,go,lua,java,ruby,php,dotnet,asm,bash,docker,emacs] [--skip ...]
set -euo pipefail

ALL=(c python node rust go lua java ruby php dotnet asm bash docker emacs)
ONLY=()
SKIP=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only) IFS=, read -ra ONLY <<<"$2"; shift 2 ;;
    --skip) IFS=, read -ra SKIP <<<"$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
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
  [[ "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *ubuntu* || "${ID_LIKE:-}" == *debian* ]] \
    || { echo "Este script é para Ubuntu/Debian (detectado: ${ID:-?})." >&2; exit 1; }
fi

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

PROFILE_SNIPPET="$HOME/.config/dotfiles-languages.sh"
mkdir -p "$(dirname "$PROFILE_SNIPPET")"
touch "$PROFILE_SNIPPET"
add_env() { grep -qxF -- "$1" "$PROFILE_SNIPPET" || echo "$1" >>"$PROFILE_SNIPPET"; }

apt_install() { $SUDO apt-get install -y --no-install-recommends "$@"; }

log "Atualizando índices do apt"
$SUDO apt-get update
apt_install ca-certificates curl git build-essential pkg-config unzip xz-utils

# ---------- C / C++ ----------
if enabled c; then
  log "C/C++: gcc, g++, clang, clangd, clang-format, cmake, gdb, make"
  apt_install gcc g++ clang clangd clang-format clang-tidy cmake ninja-build gdb make valgrind bear
fi

# ---------- Python ----------
if enabled python; then
  log "Python: python3, pip, venv, pipx + pyright"
  apt_install python3 python3-pip python3-venv python3-dev pipx
  pipx ensurepath || true
  if ! have pyright-langserver; then pipx install pyright || warn "pyright via pipx falhou"; fi
fi

# ---------- Node / JavaScript / TypeScript ----------
if enabled node; then
  log "Node.js (LTS via nvm) + typescript-language-server"
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    git clone --depth 1 --branch v0.40.1 https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  npm install -g typescript typescript-language-server
  add_env 'export NVM_DIR="$HOME/.nvm"'
  add_env '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
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
fi

# ---------- Go ----------
if enabled go; then
  log "Go + gopls"
  apt_install golang-go
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$PATH"
  go install golang.org/x/tools/gopls@latest
  add_env 'export GOPATH="$HOME/go"'
  add_env 'export PATH="$GOPATH/bin:$PATH"'
fi

# ---------- Lua ----------
if enabled lua; then
  log "Lua: lua5.4, luarocks, lua-language-server"
  apt_install lua5.4 luarocks
  if ! have lua-language-server; then
    if have snap; then
      $SUDO snap install lua-language-server --classic || warn "snap lua-language-server falhou"
    else
      warn "snap indisponível; instale lua-language-server manualmente"
    fi
  fi
fi

# ---------- Java ----------
if enabled java; then
  log "Java: OpenJDK (JDK padrão), maven, gradle"
  apt_install default-jdk maven gradle
  warn "Para eglot em java-mode, instale o jdtls (ex.: 'sudo snap install jdtls --classic' se disponível)."
fi

# ---------- Ruby (chunky-ruby, usa sorbet) ----------
if enabled ruby; then
  log "Ruby: ruby-full, bundler"
  apt_install ruby-full
  $SUDO gem install --no-document bundler sorbet solargraph || warn "gems falharam"
fi

# ---------- PHP (php-starter) ----------
if enabled php; then
  log "PHP: php-cli, composer"
  apt_install php-cli php-mbstring php-xml php-curl composer
fi

# ---------- C# / .NET (training-room) ----------
if enabled dotnet; then
  log ".NET SDK"
  apt_install dotnet-sdk-8.0 || warn "dotnet-sdk-8.0 indisponível neste Ubuntu; veja https://learn.microsoft.com/dotnet/core/install/linux-ubuntu"
fi

# ---------- Assembly (asm-blin-it: nasm x86_64 e MIPS32) ----------
if enabled asm; then
  log "Assembly: nasm, binutils, gcc-multilib, spim (MIPS)"
  apt_install nasm binutils gcc-multilib spim || warn "algum pacote de asm falhou"
fi

# ---------- Bash (bash-ing-it) ----------
if enabled bash; then
  log "Bash: shellcheck, shfmt"
  apt_install shellcheck shfmt
fi

# ---------- Docker (boxes) ----------
if enabled docker; then
  log "Docker"
  apt_install docker.io
  $SUDO usermod -aG docker "$USER" || true
fi

# ---------- Emacs Lisp / Emacs ----------
if enabled emacs; then
  log "Emacs + ferramentas usadas pelo init.el"
  # Fonte: Cascadia Code, instalada pelo apt (nenhum download de fonte).
  apt_install emacs ripgrep fd-find fonts-cascadia-code
  if [[ ! -d "$HOME/.emacs.d/.git" ]]; then
    git clone git@github.com:snake-outerheaven/emacs-config "$HOME/.emacs.d" \
      || warn "clone da config do Emacs falhou (verifique a chave SSH)"
  fi
fi

# ---------- Shell ----------
BASHRC="$HOME/.bashrc"
LINE='[ -r "$HOME/.config/dotfiles-languages.sh" ] && . "$HOME/.config/dotfiles-languages.sh"'
grep -qxF "$LINE" "$BASHRC" 2>/dev/null || echo "$LINE" >>"$BASHRC"

log "Pronto. Abra um novo shell (ou 'source ~/.bashrc') para carregar PATH/NVM."
