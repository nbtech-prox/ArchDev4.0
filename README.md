# ❄️ ArchDev v3.0 - The Elite Developer Infrastructure (Ansible Edition)

![Preview](roles/desktop/files/preview_nord.png)

<div align="center">

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Arch Linux](https://img.shields.io/badge/Arch-Linux-blue?logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible&logoColor=white)
![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-F5C2E7)

**O ambiente definitivo para produtividade extrema em Arch Linux.**
*Agora reescrito do zero com Ansible para automação profissional, idempotência e modularidade pura.*

[Instalação](#-instalação) • [Pós-Instalação](#-pós-instalação) • [Ambientes Herméticos](#-ambientes-herméticos-bubble-v30) • [Atalhos do Sistema](#-domínio-do-sistema-guia-de-atalhos-master)

</div>

---

## 💎 A Filosofia ArchDev v3.0

O **ArchDev v3.0** não é apenas uma atualização visual. É uma evolução na arquitetura. Abandonámos os scripts bash frágeis e abraçámos a **Infraestrutura como Código (IaC)** com **Ansible**.

*   **Idempotente**: O `setup.sh` pode ser corrido infinitas vezes. Ele apenas aplica o que mudou, sem duplicar configs ou partir o sistema.
*   **Modular**: Queres apenas a stack PHP? O ambiente gráfico? É tudo gerido por `roles` independentes.
*   **Seguro**: Rollbacks automáticos no boot (Btrfs + Snapper + Limine) e backups automáticos das tuas configs locais antes de qualquer alteração.
*   **Estético**: Transição completa para **Catppuccin Mocha** (GTK, Qt, Hyprland, SDDM, Terminal), substituindo o antigo Nord.

---

## 🛠️ Stack Tecnológica

### Core
- **Window Manager**: Hyprland (Wayland puro)
- **Barra**: Waybar (Estilo "Pill" Catppuccin)
- **Launcher**: Rofi (Substituto do Wofi da v2.0)
- **Terminal**: Kitty (GPU accelerated) + ZSH + Starship Prompt
- **Editor**: Neovim Pro (Lazy.nvim, LSP, Treesitter)
- **Boot**: Limine + Btrfs Assistant

### Development Ready (Últimas Versões)
- **Laravel 12 (High Performance)**:
    - **PHP 8.x**: Com todas as extensões ativas (bcmath, intl, gd, pdo, etc.).
    - **MariaDB Otimizado**: Configuração "Muscle Car" para 64GB RAM + NVMe (Buffers otimizados).
    - **Apache**: Configurado com `mpm_prefork` e suporte a vhosts.
    - **phpMyAdmin**: Pré-configurado via Apache e Socket Unix.
- **Python Ecosystem**: Poetry + Pyenv (via ASDF) para gestão hermética.
- **Docker**: Configurado (rootless opcional) e `docker-compose`.

---

## 🚀 Instalação

### 1. Pré-requisitos (Arch Linux Limpo)
Recomendamos instalar o Arch Linux usando o **`archinstall`** com estas opções críticas para garantir a resiliência do sistema:

*   **Bootloader**: Escolha **Limine** (Moderno/Rápido e nativo para snapshots).
*   **Filesystem**: Escolha **Btrfs**.
*   **Profile**: Escolha **Minimal** (sem ambiente gráfico). O nosso script instala o Hyprland.
*   **Audio**: Escolha **Pipewire**.

### 2. Passo-a-passo no Novo Sistema

```bash
# 1. Clone o repositório
git clone https://github.com/teu-usuario/ArchDev3.0.git
cd ArchDev3.0

# 2. Execute o Setup Mágico
chmod +x setup.sh
./setup.sh
```

**O que o script faz sozinho:**
1.  Verifica e instala o Ansible.
2.  Instala todos os pacotes (Pacman + AUR).
3.  Configura o sistema (Btrfs, Snapper, Plymouth).
4.  Configura a UI (Hyprland, Waybar, Catppuccin).
5.  Sincroniza os Dotfiles e Scripts.

---

## 🔧 Pós-Instalação & Manutenção

Algumas coisas requerem intervenção manual por segurança ou autenticação:

### 1. MariaDB (Segurança)
O serviço já está ativo, mas deve executar o script de segurança:
```bash
sudo mariadb-secure-installation
```
1.  Enable unix_socket auth? **N** (Importante!)
2.  Change the root password? **Y** (Defina sua senha de DB).
3.  Remove anonymous users? **Y**
4.  Disallow root login remotely? **Y**
5.  Remove test database? **Y**
6.  Reload privilege tables? **Y**

### 2. Docker
O seu utilizador já foi adicionado ao grupo `docker`. Precisa apenas de fazer **logout e login** (ou reiniciar) para funcionar sem `sudo`.

### 3. Spicetify (Spotify)
Abra o Spotify uma vez, faça login, feche-o e execute:
```bash
spicetify backup apply
```

### 4. Limpeza do Sistema
Mantenha o sistema leve:
*   `paccache -r`: Mantém apenas as 3 últimas versões de pacotes.
*   `docker system prune -a`: Remove containers e imagens não usados.

---

## 🧬 Ambientes Herméticos (Bubble v3.0)

O setup v3.0 mantém o conceito de **bolhas de ambiente** da v2.5. Cada projeto é isolado.

### O Comando `bubble`
Dentro da pasta do seu projeto, execute:

```bash
bubble [opção]
```

| Comando | Descrição | O que faz por trás dos panos? |
| :--- | :--- | :--- |
| `bubble l` | Cria bolha **Laravel / PHP** | Cria `.tool-versions` (php) e ativa `direnv` com suporte asdf. |
| `bubble p` | Cria bolha **Python** | Cria `.tool-versions` (python/poetry) e configura virtualenv local. |

**Exemplo Laravel:**
```bash
mkdir meu-projeto && cd meu-projeto
git init
bubble l
# O terminal agora usa a versão PHP definida no projeto, isolada do sistema.
```

---

## 🔄 Automação Git (Sync Offline)

Se ativar esta opção, o serviço `git-autosync` corre em background:
*   Monitoriza a sua pasta de projetos (definida na instalação).
*   A cada 5 minutos, verifica se há internet.
*   Se houver, faz `git push` automático de todos os repositórios. Perfeito para trabalhar offline e sincronizar assim que apanhar Wi-Fi.

---

## ⌨️ Domínio do Sistema (Guia de Atalhos Master)

### 🖥️ Interface & Janelas (Hyprland)
| Atalho | Ação |
| :--- | :--- |
| `Super + Enter` | Abrir Terminal (Kitty) |
| `Super + B` | Abrir Browser (Firefox) |
| `Super + E` | Abrir Explorador (Thunar) |
| `Super + Space` | Lançador de Apps (Rofi) |
| `Super + Q` | Fechar Janela Ativa |
| `Super + X` | Menu de Energia (Wlogout) |
| `Super + V` | Colar do Histórico (Cliphist) |
| `Super + L` | Bloquear Ecrã (Hyprlock) |
| `Super + Setas` | Mover Foco |
| `Super + Shift + Setas` | Mover Janela |
| `Super + 1-9` | Mudar Workspace |

### 💻 Neovim Pro (A tua IDE)
A tecla **Leader** é o `Espaço`.

| Atalho | Ação |
| :--- | :--- |
| `Space + ff` | Pesquisar Ficheiro (Telescope) |
| `Space + fg` | Pesquisar Texto (Grep) |
| `Space + e` | Abrir Árvore de Ficheiros (NvimTree/NeoTree) |
| `Space + lg` | Abrir LazyGit |
| `Space + w` | Salvar Ficheiro |
| `Space + q` | Sair |

---

## 🛡️ Segurança BTRFS (Snapshots)
A política de retenção está configurada para manter apenas os **3 últimos snapshots**.
*   O sistema cria um snapshot automático antes de cada instalação.
*   Se o sistema partir, reinicie e escolha o snapshot anterior no Boot Menu do Limine.
*   Não precisa de fazer nada manual. É automático.

---

<div align="center">
  <sub>Orgulhosamente construído para produtividade. 🚀🏁</sub>
</div>
