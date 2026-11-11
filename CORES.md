# Cores: Gruvbox escuro padrão

Guia para mexer nas cores sozinho. Tudo usa a paleta **Gruvbox dark** original (contraste médio).

## A paleta

| Nome | Normal | Clara | Uso típico |
|---|---|---|---|
| Fundo (bg) | `#282828` | — | Fundo de tudo |
| Fundo 1 (bg1) | `#3c3836` | — | Barras, painéis |
| Fundo 2 (bg2) | `#504945` | — | Bordas inativas, seleção |
| Fundo duro (bg0_h) | `#1d2021` | — | Fundo mais escuro, se quiser contraste alto |
| Texto (fg) | `#ebdbb2` | — | Texto principal |
| Cinza | `#a89984` | `#928374` | Comentários, texto apagado |
| Vermelho | `#cc241d` | `#fb4934` | Erros, palavras-chave |
| Verde | `#98971a` | `#b8bb26` | Strings, sucesso |
| Amarelo | `#d79921` | `#fabd2f` | **Destaque (janela ativa)** |
| Azul | `#458588` | `#83a598` | Links, tipos |
| Roxo | `#b16286` | `#d3869b` | Constantes |
| Ciano (aqua) | `#689d6a` | `#8ec07c` | Funções |
| Laranja | `#d65d0e` | `#fe8019` | Avisos |

**Normal** é a base. **Clara** é a versão "bright", para dar mais brilho.

## chadwm: `chadwm/.config/chadwm/chadwm/themes/gruvbox.h`

As cores ficam num arquivo de tema, com nomes de cor:

```c
static const char black[]  = "#282828"; // fundo
static const char white[]  = "#ebdbb2"; // texto
static const char gray2[]  = "#3c3836"; // borda da janela sem foco
static const char gray3[]  = "#665c54"; // tags vazias
static const char yellow[] = "#d79921"; // destaque e borda com foco
/* ... blue, green, red, orange, pink, aqua */
```

Quem usa cada nome é a tabela `colors[]` no `config.def.h`:

| Linha em `colors[]` | O que pinta | Cores (texto, fundo, borda) |
|---|---|---|
| `SchemeNorm` | Janela sem foco | `gray3`, `black`, `gray2` |
| `SchemeSel` | Janela com foco | `gray4`, `yellow`, `yellow` |
| `SchemeTitle` | Título da janela ativa | `white`, `black` |
| `SchemeTag1` a `SchemeTag5` | Cor de cada área ocupada (I a V; VI a IX repetem) | amarelo, azul, laranja, verde, ciano |
| `SchemeLayout` | Símbolo do layout (`[]=`) | `green` |
| `TabSel` / `TabNorm` | Abas | `yellow` / `gray3` |

Para mudar o destaque inteiro, troque o valor de `yellow` no `gruvbox.h`, ou troque `yellow` por outro nome na linha `SchemeSel`.

**Depois de mudar:**

```sh
cd ~/.config/chadwm/chadwm && make clean && make && doas make install
```

Depois `Super+Shift+r` reinicia o chadwm. Atenção: o `make clean` do chadwm apaga o `config.h`. Edite sempre o **`config.def.h`**.

### Barra: `chadwm/.config/chadwm/scripts/bar_themes/gruvbox`

```sh
black=#282828
yellow=#d79921   # relógio
green=#98971a    # CPU
red=#cc241d      # bateria
aqua=#689d6a     # volume
blue=#458588     # rede
```

Mudanças na barra valem ao reiniciar o `bar.sh` (ou sair e rodar `startx`).

## Terminal: `x11/.Xresources`

As cores 0 a 7 são as normais e 8 a 15 as claras, na mesma ordem da tabela: preto, vermelho, verde, amarelo, azul, roxo, ciano, cinza/branco.

```
*.background: #282828
*.foreground: #ebdbb2
*.color1:     #cc241d   ! vermelho normal
*.color9:     #fb4934   ! vermelho claro
```

**Depois de mudar:**

```sh
xrdb -merge ~/.Xresources
```

Vale para os terminais abertos **depois** do comando.

O `*.` no começo faz a cor valer para qualquer programa que lê o Xresources (xterm, e outros). O `st` **não lê** o Xresources: as cores dele ficam no `config.h` do próprio st.

## cwm: `~/.cwmrc` (se usar o cwm)

```
color activeborder   "#d79921"   # janela com foco
color inactiveborder "#504945"   # janelas sem foco
color urgencyborder  "#cc241d"   # janela pedindo atenção
color groupborder    "#458588"
color ungroupborder  "#3c3836"
color menubg         "#282828"   # fundo do menu
color menufg         "#d79921"   # item selecionado
color font           "#ebdbb2"   # texto do menu
color selfont        "#282828"   # texto do item selecionado
```

O cwm relê o arquivo sem reiniciar: menu do `cwm` → `restart`, ou `pkill -HUP cwm`.

## Fundo da tela

No `x11/.xinitrc`:

```sh
xsetroot -solid "#282828"
```

Troque por `#1d2021` para um fundo mais escuro.

## Testar uma cor antes

```sh
printf '\033[48;2;215;153;33m        \033[0m\n'   # mostra #d79921 (215,153,33 em decimal)
```

Para converter hex em decimal: `d7` = 215, `99` = 153, `21` = 33.
