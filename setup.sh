#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Iniciando Instalação do ArchDev 3.0...${NC}"
echo ""

# Verificação de sistema
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}❌ ERRO: Este script é exclusivo para Arch Linux!${NC}"
    echo ""
    echo "Detectado: $(cat /etc/os-release 2>/dev/null | grep '^NAME=' | cut -d'"' -f2 || echo 'Sistema desconhecido')"
    echo ""
    echo "Para instalar o ArchDev 3.0, você precisa:"
    echo "  1. Instalar o Arch Linux (recomendado: archinstall)"
    echo "  2. Escolher: BTRFS + Limine + Minimal"
    echo "  3. Depois executar este script"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Arch Linux detectado${NC}"
echo ""

# 1. Update e instalação do Ansible (garante que temos o motor)
if ! command -v ansible &> /dev/null
then
    echo -e "${BLUE}>>> Instalando Ansible...${NC}"
    sudo pacman -S --noconfirm ansible
else
    echo -e "${GREEN}>>> Ansible já instalado.${NC}"
fi

# 2. Instalação das dependências do Galaxy (se houver roles externas)
# echo -e "${BLUE}>>> Instalando roles do Ansible Galaxy...${NC}"
# ansible-galaxy install -r roles/requirements.yml

# 3. Snapshot de Segurança BTRFS (Prevenção)
echo -e "${BLUE}>>> Verificando sistema de ficheiros para Snapshot de segurança...${NC}"
if command -v snapper &> /dev/null && sudo snapper -c root get-config &> /dev/null; then
    echo -e "${YELLOW}>>> Criando Snapshot BTRFS (Pre-ArchDev3-Setup)...${NC}"
    sudo snapper -c root create --description "Pre-ArchDev3-Setup" --cleanup-algorithm number
else
    echo -e "${YELLOW}>>> Snapper não detetado/configurado. Snapshot inicial ignorado (será configurado pelo Ansible).${NC}"
fi
echo ""

# 4. Execução do Playbook Principal
echo -e "${BLUE}>>> Aplicando configurações do ArchDev 3.0 (Isso pode demorar)...${NC}"
# -K pede a senha de sudo no início (necessário para yay/AUR)
ansible-playbook playbooks/site.yml -K

echo -e "${GREEN}>>> Instalação Concluída! Reinicie a sessão para aplicar todas as mudanças.${NC}"
