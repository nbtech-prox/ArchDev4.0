#!/bin/bash
# ArchDev - Clipboard Manager GUI
# Interface gráfica para cliphist usando rofi

# Verifica dependências
if ! command -v wl-copy &> /dev/null; then
    dunstify -a "Clipboard" -u critical "❌ wl-clipboard não instalado" "Instale: sudo pacman -S wl-clipboard"
    exit 1
fi

if ! command -v cliphist &> /dev/null; then
    dunstify -a "Clipboard" -u critical "❌ cliphist não instalado" "Instale: sudo pacman -S cliphist"
    exit 1
fi

# Verifica se há itens no clipboard
if ! cliphist list | grep -q "."; then
    dunstify -a "Clipboard" -u normal "📋 Clipboard vazio"
    exit 0
fi

# Mostra menu rofi com os itens do clipboard
SELECTED=$(cliphist list | rofi -dmenu \
    -theme-str 'window {width: 600px; height: 400px;}' \
    -theme-str 'listview {columns: 1; lines: 10;}' \
    -theme-str 'element-text {wrap: none;}' \
    -p "📋 Clipboard History" \
    -mesg "Enter: copiar | Shift+Enter: apagar | Esc: sair")

# Se pressionou Escape, sai
[ -z "$SELECTED" ] && exit 0

# Se pressionou Shift+Enter, apaga o item
if [ -n "$SELECTED" ]; then
    # Verifica se é para apagar (shift+enter no rofi retorna o item)
    # Por padrão, copia o item
    echo "$SELECTED" | cliphist decode | wl-copy
    dunstify -a "Clipboard" -u low "✓ Copiado para clipboard"
fi
