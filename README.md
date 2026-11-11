# about

my dotfiles, to be used with [GNU stow](https://www.gnu.org/savannah-checkouts/gnu/stow/stow.html)

## language setup

- `setup/setup-languages-fedora.sh` – Fedora 44 (C/C++, Rust, Go, Assembly, Java)
- `setup/setup-languages-ubuntu.sh` – Ubuntu/Debian

Both accept `--only c,rust,...` / `--skip ...`.

## dwm (branch `dwm`): chadwm em Gruvbox

Base: [chadwm](https://github.com/siduck/chadwm), de siduck (licença MIT, em `chadwm/.config/chadwm/LICENSE`), um dwm 6.5 com patches (gaps, abas, barra colorida, ícones). Adaptado aqui para OpenBSD, Gruvbox escuro padrão (destaque amarelo), Cascadia Code e áreas de trabalho de I a IX.

- `chadwm/` – pacote do stow: vira `~/.config/chadwm/` (código em `chadwm/`, barra e autostart em `scripts/`).
- `x11/` – pacote do stow: `.xinitrc` (chama o `run.sh`) e `.Xresources` (paleta Gruvbox completa).
- `CORES.md` – guia de todas as cores.

```sh
doas pkg_add imlib2 dmenu st         # dependencias
stow chadwm x11                      # cria ~/.config/chadwm, ~/.xinitrc e ~/.Xresources
cd ~/.config/chadwm/chadwm && make && doas make install   # instala como /usr/local/bin/chadwm
startx
```

Ícones da barra pedem a fonte **CaskaydiaCove Nerd Font Mono** (Cascadia em versão Nerd Font) em `~/.fonts`.

O que foi trocado do chadwm original para o OpenBSD:

| Original (Linux) | Aqui |
|---|---|
| `pactl` (volume) | `sndioctl` |
| `light` (brilho) | `xbacklight` |
| `rofi` e `eww` | `dmenu_run` |
| `killall` | `pkill` |
| barra com `/proc` e `/sys` | barra com `sysctl`, `apm`, `sndioctl` e `ifconfig` |
| caminhos do Linux no `config.mk` | `${X11INC}/freetype2` e `/usr/local` (imlib2) |

Atalhos usam a tecla **Super**: `Super+Enter` terminal, `Super+c` menu, `Super+q` fecha, `Super+1..9` áreas, `Super+Ctrl+q` sai.
