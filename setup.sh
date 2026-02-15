#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Iniciando Instalação do ArchDev 3.0...${NC}"

# 1. Update e instalação do Ansible (garante que temos o motor)
if ! command -v ansible &> /dev/null
then
    echo -e "${BLUE}>>> Instalando Ansible...${NC}"
    if [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm ansible
    elif [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y ansible
    else
        echo "Gestor de pacotes não suportado. Instale Ansible manualmente."
        exit 1
    fi
else
    echo -e "${GREEN}>>> Ansible já instalado.${NC}"
fi

# 2. Instalação das dependências do Galaxy (se houver roles externas)
# echo -e "${BLUE}>>> Instalando roles do Ansible Galaxy...${NC}"
# ansible-galaxy install -r roles/requirements.yml

# 3. Execução do Playbook Principal
echo -e "${BLUE}>>> Aplicando configurações do ArchDev 3.0 (Isso pode demorar)...${NC}"
# -K pede a senha de sudo no início (necessário para yay/AUR)
ansible-playbook playbooks/site.yml -K

echo -e "${GREEN}>>> Instalação Concluída! Reinicie a sessão para aplicar todas as mudanças.${NC}"
