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
| Amarelo | `#d79921` | `#fabd2f` | Amarelo do terminal |
| Amarelo apagado (faded) | `#b57614` | — | **Destaque da barra (janela ativa)** |
| Azul | `#458588` | `#83a598` | Links, tipos |
| Roxo | `#b16286` | `#d3869b` | Constantes |
| Ciano (aqua) | `#689d6a` | `#8ec07c` | Funções |
| Laranja | `#d65d0e` | `#fe8019` | Avisos |

**Normal** é a base. **Clara** é a versão "bright", para dar mais brilho. **Apagada** (faded) é a versão mais escura, que o Gruvbox usa no tema claro; aqui ela serve de destaque discreto.

## dwm: `dwm/config.h`

```c
static const char col_gray1[] = "#282828"; /* fundo da barra          */
static const char col_gray2[] = "#504945"; /* borda da janela inativa */
static const char col_gray3[] = "#ebdbb2"; /* texto da barra          */
static const char col_gray4[] = "#282828"; /* texto sobre o destaque  */
static const char col_cyan[]  = "#b57614"; /* destaque: tag ativa, título e borda ativa (amarelo apagado) */
```

Os nomes (`col_gray1`, `col_cyan`) vêm do dwm original. O nome não importa, o valor sim.

| Variável | Onde aparece |
|---|---|
| `col_gray1` | Fundo da barra e das tags inativas |
| `col_gray2` | Borda das janelas sem foco |
| `col_gray3` | Texto das tags inativas e do status |
| `col_gray4` | Texto da tag ativa e do título |
| `col_cyan` | Fundo da tag ativa, do título e borda da janela com foco |

O `dmenu` usa as mesmas variáveis (`dmenucmd` no `config.h`).

**Depois de mudar:**

```sh
cd dwm && make && doas make install
```

Saia do dwm (`Alt+Shift+q`) e rode `startx` de novo. O dwm não relê cores sem recompilar.

### Trocas rápidas de destaque

| Quer o destaque em | Troque `col_cyan` por |
|---|---|
| Amarelo apagado (atual) | `#b57614` |
| Amarelo normal | `#d79921` |
| Amarelo claro | `#fabd2f` |
| Azul | `#458588` |
| Verde | `#98971a` |
| Laranja | `#d65d0e` |
| Discreto, sem cor | `#504945` (e `col_gray4` para `#ebdbb2`) |

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
color activeborder   "#b57614"   # janela com foco (mesmo destaque do dwm)
color inactiveborder "#504945"   # janelas sem foco
color urgencyborder  "#cc241d"   # janela pedindo atenção
color groupborder    "#458588"
color ungroupborder  "#3c3836"
color menubg         "#282828"   # fundo do menu
color menufg         "#b57614"   # item selecionado
color font           "#ebdbb2"   # texto do menu
color selfont        "#282828"   # texto do item selecionado
```

O cwm relê o arquivo sem reiniciar: menu do `cwm` → `restart`, ou `pkill -HUP cwm`.

## tmux: `tmux/.tmux.conf`

| Opção | Cor | Papel |
|---|---|---|
| `status-style` | fundo `#282828`, texto `#a89984` | Barra |
| nome da sessão | `#98971a` | Verde normal |
| relógio | `#d79921` | Amarelo normal |
| título do painel | `#689d6a` | Ciano normal |
| janela atual | fundo `#b57614`, texto `#282828` | Mesmo destaque do dwm |
| bordas | `#3c3836`, ativa `#b57614` | Divisões |

Aplicar: `Ctrl+b r` (recarrega a config).

## Prompt: `starship/.config/starship.toml`

A paleta `gruvbox_dark` define os nomes `red`, `green`, `blue`, `purple` etc. com as cores **claras** do Gruvbox, que leem melhor no fundo escuro. Os módulos usam esses nomes (`style = "blue bold"`). Para mudar uma cor do prompt, troque o hex na paleta.

## vim e fish

Não têm cor própria: usam as 16 cores do terminal. Como o `.Xresources` já é Gruvbox, eles saem em Gruvbox. Se um dia quiser um tema de vim, o Vim 9 traz o `retrobox`, inspirado no Gruvbox (`:colorscheme retrobox`).

## Fundo da tela

No `x11/.xinitrc`:

```sh
xsetroot -solid "#282828"
```

Troque por `#1d2021` para um fundo mais escuro.

## Testar uma cor antes

```sh
printf '\033[48;2;181;118;20m        \033[0m\n'   # mostra #b57614 (181,118,20 em decimal)
```

Para converter hex em decimal: `b5` = 181, `76` = 118, `14` = 20.
