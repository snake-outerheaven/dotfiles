# about

my dotfiles, to be used with [GNU stow](https://www.gnu.org/savannah-checkouts/gnu/stow/stow.html)

## language setup

- `setup/setup-languages-fedora.sh` – Fedora 44 (C/C++, Rust, Go, Assembly, Java)
- `setup/setup-languages-ubuntu.sh` – Ubuntu/Debian

Both accept `--only c,rust,...` / `--skip ...`.

## dwm (branch `dwm`)

dwm 6.4 em Gruvbox escuro padrão (destaque amarelo), com fonte Cascadia Code e áreas de trabalho em algarismos romanos (I a IX), configurado para OpenBSD.

- `dwm/` – código-fonte do dwm com o `config.h` pronto. **Não é pacote do stow**: compila e instala.
- `x11/` – pacote do stow com `.xinitrc` (barra com data, bateria e volume) e `.Xresources` (paleta Gruvbox completa).
- `CORES.md` – guia de todas as cores, para configurar sozinho.

```sh
doas pkg_delete dwm          # se o dwm do pacote estiver instalado
cd dwm && make && doas make install
cd .. && stow x11            # cria ~/.xinitrc e ~/.Xresources
startx
```

O `config.mk` já usa os caminhos do OpenBSD (`${X11INC}/freetype2`). O terminal (`Alt+Shift+Enter`) é o `st` (`doas pkg_add st`).
