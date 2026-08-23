#!/usr/bin/env bash
set -euo pipefail

echo "==> Atualizando pacotes base"
sudo dnf upgrade -y

echo "==> Instalando CLI / produtividade"
sudo dnf install -y \
  git git-lfs gh vim neovim tmux zsh fish \
  htop btop tree wget curl unzip jq \
  ripgrep fd-find fzf bat

echo "==> Instalando Nerd Fonts"
NERD_FONTS_DIR="$HOME/.fonts"
NERD_FONTS_TMP="$(mktemp -d)"
trap 'rm -rf "$NERD_FONTS_TMP"' EXIT
mkdir -p "$NERD_FONTS_DIR"

NERD_FONTS=(
  Gohu
  ComicShannsMono
  AdwaitaMono
  Iosevka
  FiraCode
)

for  nerd_font in "${NERD_FONTS[@]}"; do
  nerd_font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${nerd_font}.zip"
  wget -q --show-progress -P "$NERD_FONTS_TMP" "$nerd_font_url"
  unzip -oq "$NERD_FONTS_TMP/${nerd_font}.zip" -d "$NERD_FONTS_DIR"
done
fc-cache -f "$NERD_FONTS_DIR" 2>/dev/null || true

echo "==> Instalando Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh já instalado, pulando."
fi

echo "==> Instalando toolchain multi-linguagem"
sudo dnf install -y \
  gcc gcc-c++ clang make cmake ninja-build pkgconf-pkg-config gdb valgrind \
  golang \
  java-latest-openjdk java-latest-openjdk-devel maven \
  python3 python3-pip python3-virtualenv python3-devel pipx

echo "==> Instalando Rust via rustup (pacote do dnf)"
if ! command -v rustup >/dev/null 2>&1; then
  sudo dnf install -y rustup
  rustup-init -y --default-toolchain stable --component rust-analyzer
  source "$HOME/.cargo/env"
else
  echo "rustup já instalado, pulando."
fi
if ! grep -q '.cargo/env' "$HOME/.zshrc" 2>/dev/null; then
  echo '. "$HOME/.cargo/env"' >> "$HOME/.zshrc"
fi

echo "==> Instalando GNU Stow"
sudo dnf install -y stow

echo "==> Instalando dependências pra exportar apps GUI pro host"
sudo dnf install -y dbus-x11 xdg-utils desktop-file-utils

echo "==> Instalando ferramentas de container (rootless, sem precisar de systemd)"
sudo dnf install -y podman podman-docker buildah skopeo

echo "==> Configurando chave SSH"
sudo dnf install -y openssh-clients
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
  echo "Chave já existe em $SSH_KEY, pulando geração."
else
  ssh-keygen -t ed25519 -f "$SSH_KEY"
  chmod 600 "$SSH_KEY"
  chmod 644 "${SSH_KEY}.pub"
fi
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY"
if ! grep -q "ssh-agent" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
EOF
fi

echo "==> Adicionando repo Terra e instalando bun (bun-bin)"
sudo dnf install -y --nogpgcheck \
  --repofrompath "terra,https://repos.fyralabs.com/terra44" \
  terra-release terra-gpg-keys
sudo dnf install -y bun-bin

echo "==> Adicionando repo do VS Code (Microsoft) e instalando"
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

echo "==> Exportando o VS Code pro menu de apps do host"
distrobox-export --app code

echo "==> Definindo zsh como shell padrão dentro da box"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo ""
echo "==> Chave pública SSH (adicione no GitHub/GitLab/etc.):"
cat "$SSH_KEY.pub"

echo ""
echo "==> Tudo pronto. Feche e reabra o terminal (ou rode 'exec zsh') pra usar o novo shell."
