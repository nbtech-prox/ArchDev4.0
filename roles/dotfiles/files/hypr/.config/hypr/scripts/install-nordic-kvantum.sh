#!/bin/bash
# Script para instalar o tema Nordic no Kvantum manualmente

echo "Instalando tema Nordic para Kvantum..."

# Cria o diretório de temas do Kvantum se não existir
mkdir -p ~/.config/Kvantum

# Baixa o tema Nordic do GitHub
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit

git clone https://github.com/EliverLara/Nordic.git

# Copia os temas Kvantum para o diretório correto
if [ -d "Nordic/kde/kvantum" ]; then
    cp -r Nordic/kde/kvantum/* ~/.config/Kvantum/
    echo "✓ Tema Nordic instalado com sucesso!"
    echo "Abre o Kvantum Manager e seleciona 'Nordic' ou 'Nordic-Darker'"
else
    echo "✗ Estrutura do tema não encontrada. Tentando método alternativo..."
    # Tenta copiar diretamente se a estrutura for diferente
    find Nordic -type d -name "*Nordic*" -exec cp -r {} ~/.config/Kvantum/ \;
fi

# Limpa arquivos temporários
cd ~ || exit
rm -rf "$TEMP_DIR"

echo "Instalação concluída!"
