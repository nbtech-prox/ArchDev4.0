#!/bin/bash
# Script para reiniciar a Waybar com verificação de erros

echo "Parando Waybar..."
killall waybar 2>/dev/null

sleep 0.5

echo "Verificando configuração..."
if ! waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css --log-level debug 2>&1 | head -20; then
    echo "Erro na configuração detectado!"
fi

echo "Iniciando Waybar..."
waybar &

echo "Waybar reiniciada!"
