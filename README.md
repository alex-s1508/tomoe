<p align="center">
  <img src="dotfiles/assets/images/tomoe-header.png" width="760" alt="Chie Satonaka">
</p>
<h3 align="center">T O M O E &ensp;巴</h3>

<p align="center"><em>Umbriel + Noctalia</em></p>
<p align="center">Chie Satonaka theme · Persona 4</p>

# Como instalar

```sh
git clone https://github.com/alex-s1508/tomoe.git
cd tomoe
./tomoe install
```

O instalador imprime o cabeçalho, pede a senha do `sudo` uma única vez e
pergunta no idioma do PC se deve instalar a T O M O E 巴 dotfile. Depois
roda com barra de progresso e log inteligente, instala pacotes, copia as
configurações, valida o Umbriel e o Noctalia, configura o greetd e oferece
reiniciar o computador.

# O que é instalado

- Umbriel, Noctalia, Kitty, Noctalia Greeter (com greetd) e Nautilus.
- Google Chrome e Visual Studio Code pela AUR, usando `yay`.
- Configuração modular do Umbriel em `~/.config/umbriel/`.
- Configuração do Noctalia (paleta M3 monocromática, polkit) em
  `~/.config/noctalia/`, com papel de parede em `XDG_PICTURES_DIR/Wallpapers`.
- Configuração do greetd em `/etc/greetd/config.toml`.
- Flags do Chrome, atalhos ocultos e bookmarks do Nautilus.

# Estrutura

```
dotfiles/
  config/       configurações instaladas
  packages/     listas de pacotes
  assets/       ASCII, imagens e wallpapers
```

# Personalização

Os pacotes ficam em `dotfiles/packages/`:

| Arquivo | Função |
|---|---|
| `repo.txt` | Pacotes dos repositórios oficiais. |
| `aur.txt` | Pacotes da AUR instalados com `yay`. |
| `remove.txt` | Pacotes do CachyOS removidos quando seguros. |

As configurações do Umbriel ficam em `dotfiles/config/umbriel/`, um arquivo por
tópico. O `config.toml` apenas inclui os demais; `apps.toml` concentra os
atalhos de aplicativos padrão. Valide suas mudanças com:

```sh
umbriel config validate
noctalia config validate
```

# Atalhos principais

| Atalho | Ação |
|---|---|
| `Mod+Return` | Terminal (kitty) |
| `Mod+B` | Navegador padrão |
| `Mod+E` | Gerenciador de arquivos (Nautilus) |
| `Mod+Space` | Launcher do Noctalia |
| `Mod+S` | Scratchpad |
| `Mod+Shift+S` | Próximo foco do scratchpad |
| `Mod+Tab` | Overview |
| `Alt+Tab` | Alternador de janelas estilo Windows |
| `Mod+F` | Maximizar para as bordas |
| `Mod+Shift+F` | Tela cheia |

# Comandos

```sh
./tomoe install              # instala e configura
./tomoe install --dry-run    # mostra o que seria feito
./tomoe install --yes        # instala sem confirmação
./tomoe install --reboot     # reinicia ao terminar
```

Backups ficam em `~/.local/state/tomoe/backups/`. O log da instalação fica em
`~/.local/state/tomoe/`.