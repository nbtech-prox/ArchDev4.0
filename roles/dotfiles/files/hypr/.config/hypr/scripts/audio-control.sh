#!/bin/bash
# Script para configurar o áudio padrão e abrir o pavucontrol

# Lista todos os dispositivos de áudio disponíveis
echo "=== Dispositivos de Áudio Disponíveis ==="
wpctl status | grep -A 20 "Audio"

echo ""
echo "=== Configuração Atual ==="
DEFAULT_SINK=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "node.name" | cut -d'"' -f2)
echo "Saída padrão atual: $DEFAULT_SINK"

# Se o pavucontrol estiver instalado, abre-o
if command -v pavucontrol &> /dev/null; then
    pavucontrol &
else
    echo "AVISO: pavucontrol não está instalado!"
    echo "Instala com: sudo pacman -S pavucontrol"
fi
