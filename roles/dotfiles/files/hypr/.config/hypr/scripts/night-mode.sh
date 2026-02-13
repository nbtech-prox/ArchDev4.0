#!/bin/bash
# ArchDev - Night Mode Toggle
# Liga/desliga o filtro de luz azul (wlsunset)

PID=$(pgrep -x wlsunset)

if [ -n "$PID" ]; then
    # Está ligado, desligar
    kill $PID
    dunstify -a "Night Mode" -u normal "☀️ Modo Dia ativado" "Filtro de luz azul desligado"
else
    # Está desligado, ligar
    wlsunset -T 6500 -t 4500 &
    dunstify -a "Night Mode" -u normal "🌙 Modo Noite ativado" "Filtro de luz azul ligado (6500K → 4500K)"
fi
