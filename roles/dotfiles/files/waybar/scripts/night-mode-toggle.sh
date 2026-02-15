#!/bin/bash
# Waybar Night Mode Toggle Script
# Liga/desliga o wlsunset (filtro de luz azul)

# Verifica se wlsunset está instalado
if ! command -v wlsunset &> /dev/null; then
    echo '{"text": "󰌵", "tooltip": "wlsunset não instalado", "class": "off"}'
    exit 1
fi

# Verifica se wlsunset está a correr
PID=$(pgrep -x wlsunset)

# Função para retornar status atual
show_status() {
    if [ -n "$PID" ]; then
        echo '{"text": "󰌵", "tooltip": "Night Mode: ON (clique para desligar)", "class": "on"}'
    else
        echo '{"text": "󰌶", "tooltip": "Night Mode: OFF (clique para ligar)", "class": "off"}'
    fi
}

# Se for chamado com argumento "toggle", alterna o estado
# Se não tiver argumento, apenas mostra o status (para o interval do waybar)
if [ "$1" == "toggle" ]; then
    if [ -n "$PID" ]; then
        # Está ligado, desligar
        kill "$PID" 2>/dev/null || killall -9 wlsunset 2>/dev/null
        # Notificação
        dunstify -a "Night Mode" -u normal "☀️ Modo Dia ativado" "Filtro de luz azul desligado"
    else
        # Está desligado, ligar
        wlsunset -T 6500 -t 4500 &
        # Notificação
        dunstify -a "Night Mode" -u normal "🌙 Modo Noite ativado" "Filtro de luz azul ligado (6500K → 4500K)"
    fi
fi

# Sempre retorna o status atual
show_status
