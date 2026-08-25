#!/usr/bin/env bash
# ============================================================
# Script de configuração para Distrobox – "Develop Everything"
# Inclui: C, C++, Go, Java, Python, Node, Rust, infra, containers,
#         Wine, e cross-compilação Windows (MinGW-w64)
# ============================================================
set -euo pipefail
DEBUG=${DEBUG:-0}
[ "$DEBUG" -eq 1 ] && set -x

# ------------------- VARIÁVEIS GLOBAIS -----------------------
DOTFILES_DIR="${HOME}/dotfiles"
SSH_KEY="${HOME}/.ssh/id_ed25519"
NERD_FONTS_DIR="${HOME}/.fonts"
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

# ------------------- FUNÇÕES AUXILIARES ----------------------
install_if_missing() {
  local to_install=()
  for pkg in "$@"; do
    rpm -q "$pkg" &>/dev/null || to_install+=("$pkg")
  done
  if [ ${#to_install[@]} -gt 0 ]; then
    echo "→ Instalando: ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
  fi
}

add_repo_if_missing() {
  local repo_file="$1"
  [ -f "$repo_file" ] && return 0
  shift
  echo "→ Adicionando repositório: $repo_file"
  sudo dnf install -y --nogpgcheck "$@"
}

command_exists() {
  command -v "$1" &>/dev/null
}

# ------------------- 1. ATUALIZAÇÃO DO SISTEMA ----------------
echo "==> Atualizando pacotes base"
sudo dnf upgrade -y

# ------------------- 2. PACOTES BASE E PRODUTIVIDADE ----------
echo "==> Instalando pacotes base e de produtividade"
BASE_PKGS=(
  zsh fish bash-completion
  tmux screen
  htop btop
  tree wget curl unzip jq
  ripgrep fd-find fzf bat
  vim neovim
  git git-lfs gh
  stow rsync openssh-clients
  dbus-x11 xdg-utils desktop-file-utils
  podman podman-docker buildah skopeo
  sudo ncdu duf
)
install_if_missing "${BASE_PKGS[@]}"

# ------------------- 3. FERRAMENTAS DE DESENVOLVIMENTO --------
echo "==> Instalando compiladores, linguagens e build tools"
DEV_PKGS=(
  gcc gcc-c++ clang clang-tools-extra
  make cmake ninja-build pkgconf-pkg-config
  gdb valgrind
  golang
  java-latest-openjdk java-latest-openjdk-devel maven
  python3 python3-pip python3-virtualenv python3-devel pipx
  nodejs22 nodejs22-npm
  ruby ruby-devel
  perl perl-utils
)
install_if_missing "${DEV_PKGS[@]}"

# ------------------- 4. FERRAMENTAS DE INFRA E CLOUD ----------
echo "==> Instalando ferramentas de infraestrutura"
# Repositório HashiCorp (Terraform)
if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
  sudo dnf config-manager --add-repo \
    https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
fi
install_if_missing terraform

# Repositório Kubernetes
if [ ! -f /etc/yum.repos.d/kubernetes.repo ]; then
  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOF
fi
install_if_missing kubectl helm

# Ferramentas via Go
if command_exists go; then
  go install github.com/derailed/k9s@latest
  go install sigs.k8s.io/kind@latest
fi

# ------------------- 5. RUST (via rustup) ---------------------
if ! command_exists rustc; then
  install_if_missing rustup
  rustup-init -y --default-toolchain stable --component rust-analyzer
fi

# ------------------- 6. NODE.JS TOOLS (global) ---------------
if command_exists npm; then
  sudo npm install -g yarn pnpm typescript ts-node nodemon
fi

# ------------------- 7. PYTHON TOOLS (via pipx) ---------------
if command_exists pipx; then
  pipx install poetry black pylint mypy ruff
fi

# ------------------- 8. BANCO DE DADOS E CLIENTES ------------
echo "==> Instalando clientes de banco de dados"
DB_PKGS=(sqlite postgresql mysql redis)
install_if_missing "${DB_PKGS[@]}"

# =================== NOVAS SEÇÕES ==============================
# ------------------- 9. WINE -----------------------------------
echo "==> Instalando Wine (para executar aplicativos Windows)"
WINE_PKGS=(
  wine wine-core wine-alsa wine-pulseaudio
  wine-cms wine-ldap wine-opencl wine-twain
  wine-desktop wine-fonts
  # Pacotes de fontes Windows (opcionais, mas úteis)
  wine-arial-winefonts wine-courier-winefonts
  wine-ms-sans-serif-winefonts wine-small-winefonts
  wine-system-winefonts wine-tahoma-winefonts
  wine-times-new-roman-winefonts wine-webdings-winefonts
  wine-wingdings-winefonts
)
install_if_missing "${WINE_PKGS[@]}"

# Inicializar o prefixo do Wine (se não existir)
if [ ! -d "$HOME/.wine" ]; then
  echo "→ Inicializando Wine (cria ~/.wine)"
  wineboot --init 2>/dev/null || true
fi

# ------------------- 10. MINGW-W64 (C/C++ cross para Windows) --
echo "==> Instalando toolchain MinGW-w64 (cross-compilação para Windows)"
MINGW_PKGS=(
  mingw64-gcc mingw64-gcc-c++ mingw64-binutils
  mingw64-crt mingw64-headers mingw64-winpthreads
  mingw64-filesystem
  mingw32-gcc mingw32-gcc-c++ mingw32-binutils  # (opcional, 32-bit)
  mingw32-crt mingw32-headers mingw32-winpthreads
  mingw32-filesystem
  # Bibliotecas úteis para cross-compilação
  mingw64-libxml2 mingw64-libxslt mingw64-zlib
  mingw64-libpng mingw64-libtiff mingw64-libjpeg-turbo
  mingw64-SDL3 mingw64-lcms2
)
install_if_missing "${MINGW_PKGS[@]}"

# Criar um arquivo de toolchain para CMake (exemplo)
TOOLCHAIN_FILE="$HOME/toolchain-mingw64.cmake"
if [ ! -f "$TOOLCHAIN_FILE" ]; then
  cat > "$TOOLCHAIN_FILE" <<'EOF'
# CMake toolchain file para cross-compilação Windows (MinGW-w64)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Compiladores
set(CMAKE_C_COMPILER   x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER  x86_64-w64-mingw32-windres)
set(CMAKE_AR           x86_64-w64-mingw32-ar)
set(CMAKE_RANLIB       x86_64-w64-mingw32-ranlib)

# Diretórios de busca
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
  echo "→ Arquivo de toolchain CMake criado em $TOOLCHAIN_FILE"
fi

# Adicionar um alias no .zshrc para compilar facilmente
if ! grep -q "mingw64" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'
# Alias para compilar para Windows com MinGW
alias mingw64-gcc='x86_64-w64-mingw32-gcc'
alias mingw64-g++='x86_64-w64-mingw32-g++'
alias mingw64-cmake='cmake -DCMAKE_TOOLCHAIN_FILE=~/toolchain-mingw64.cmake'
EOF
fi

# =================== FIM DAS NOVAS SEÇÕES ======================

# ------------------- 11. FONTES NERD FONTS --------------------
echo "==> Baixando Nerd Fonts (FiraCode e Iosevka)"
mkdir -p "$NERD_FONTS_DIR"
for font in FiraCode Iosevka; do
  zip_path="$NERD_FONTS_DIR/${font}.zip"
  if [ ! -d "$NERD_FONTS_DIR/$font" ] && [ ! -f "$zip_path" ]; then
    wget -q --show-progress -O "$zip_path" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
    unzip -qo "$zip_path" -d "$NERD_FONTS_DIR"
    rm -f "$zip_path"
  fi
done
fc-cache -f "$NERD_FONTS_DIR" 2>/dev/null || true

# ------------------- 12. CONFIGURAÇÃO SSH --------------------
echo "==> Configurando chave SSH"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$SSH_KEY" ]; then
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "distrobox-$(hostname)"
  chmod 600 "$SSH_KEY"
  chmod 644 "${SSH_KEY}.pub"
fi

if ! grep -q "ssh-agent" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
EOF
fi

# ------------------- 13. REPOSITÓRIOS EXTRAS -----------------
add_repo_if_missing /etc/yum.repos.d/terra.repo \
  --repofrompath "terra,https://repos.fyralabs.com/terra44" \
  terra-release terra-gpg-keys
install_if_missing bun-bin

if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
  echo "==> Adicionando repositório do VS Code"
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
  sudo dnf install -y code
else
  install_if_missing code
fi

command_exists distrobox-export && distrobox-export --app code

# ------------------- 14. SHELL ZSH E OH-MY-ZSH ---------------
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  sudo chsh -s /usr/bin/zsh "$(whoami)" 2>/dev/null || echo "Altere manualmente o shell para zsh"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Instalando Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

if ! grep -q "plugins=(git" "$HOME/.zshrc"; then
  sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl helm terraform)/' "$HOME/.zshrc"
fi

if ! grep -q '.cargo/env' "$HOME/.zshrc"; then
  echo '. "$HOME/.cargo/env"' >> "$HOME/.zshrc"
fi

# ------------------- 15. FERRAMENTAS ADICIONAIS VIA GO --------
if command_exists go; then
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  go install github.com/go-delve/delve/cmd/dlv@latest
  go install honnef.co/go/tools/cmd/staticcheck@latest
fi

# ------------------- 16. LIMPEZA E FINALIZAÇÃO ----------------
echo ""
echo "==> Chave pública SSH (adicione no GitHub/GitLab/etc.):"
cat "$SSH_KEY.pub"
echo ""
echo "✅ Configuração concluída com sucesso!"
echo "   - Feche e reabra o terminal ou execute 'exec zsh'"
echo "   - Para compilar para Windows com MinGW:"
echo "       * Use os aliases: mingw64-gcc, mingw64-g++, mingw64-cmake"
echo "       * Exemplo: mingw64-gcc -o hello.exe hello.c"
echo "       * CMake: mingw64-cmake .. && make"
echo "   - Para executar .exe com Wine: wine hello.exe"
echo "   - O arquivo de toolchain CMake está em ~/toolchain-mingw64.cmake"
echo "   - O VS Code foi exportado para o host (se estiver na Distrobox)"
