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
    wlsunset -l 38.7 -L -9.1 &
    dunstify -a "Night Mode" -u normal "🌙 Modo Auto retomado" "Filtro dinâmico sincronizado com o pôr-do-sol"
fi
