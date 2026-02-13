#!/bin/bash
# Script para instalar o tema Catppuccin Mocha no Kvantum manualmente

echo "Instalando tema Catppuccin Mocha para Kvantum..."

# Cria o diretório de temas do Kvantum se não existir
mkdir -p ~/.config/Kvantum

# Baixa o tema Catppuccin do GitHub
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit

git clone https://github.com/catppuccin/Kvantum.git

# Copia os temas Kvantum para o diretório correto
if [ -d "Kvantum/themes" ]; then
    cp -r Kvantum/themes/* ~/.config/Kvantum/
    echo "✓ Tema Catppuccin instalado com sucesso!"
    echo "Abre o Kvantum Manager e seleciona 'Catppuccin-Mocha-Blue' ou outra variante"
else
    echo "✗ Estrutura do tema não encontrada. Tentando método alternativo..."
    # Tenta copiar diretamente se a estrutura for diferente
    find Kvantum -type d -name "*Catppuccin*" -exec cp -r {} ~/.config/Kvantum/ \;
fi

# Limpa arquivos temporários
cd ~ || exit
rm -rf "$TEMP_DIR"

echo "Instalação concluída!"
