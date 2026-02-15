#!/bin/bash
# Script de controle de volume - Amplificação até 150%

# Encontra o ID do Bluetooth STN-01 dinamicamente (corrige problema de formatação)
BT_ID=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep "STN-01" | grep -oE '[0-9]+\.' | head -1 | tr -d '.')

case "$1" in
    up)
        # Limite aumentado para 1.5 (150%)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        # Controla Bluetooth se estiver conectado
        [ -n "$BT_ID" ] && wpctl set-volume -l 1.5 "$BT_ID" 5%+ 2>/dev/null
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        [ -n "$BT_ID" ] && wpctl set-volume "$BT_ID" 5%- 2>/dev/null
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        [ -n "$BT_ID" ] && wpctl set-mute "$BT_ID" toggle 2>/dev/null
        ;;
esac
