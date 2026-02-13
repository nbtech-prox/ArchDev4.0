#!/bin/bash
# ArchDev - Waybar Update Notifier
# Mostra notificação e abre terminal para atualizar quando clicado

# Verifica updates
UPDATES=$(checkupdates 2>/dev/null | wc -l)

if [ "$UPDATES" -eq 0 ]; then
    echo "📦 0"
    exit 0
else
    echo "📦 $UPDATES"
fi

# Quando clicado
if [ "$1" == "click" ]; then
    # Mostra notificação com detalhes
    DETAILS=$(checkupdates 2>/dev/null | head -10)
    if [ "$UPDATES" -gt 10 ]; then
        DETAILS+="\n... e mais $(($UPDATES - 10)) pacotes"
    fi
    
    dunstify -a "Waybar Updates" \
             -u normal \
             -r 9991 \
             "📦 $UPDATES atualizações disponíveis" \
             "$DETAILS" \
             -a "Clique para atualizar"
    
    # Abre kitty com yay
    kitty -e sh -c 'echo "📦 Atualizando sistema..."; yay -Syu; echo "✅ Concluído! Pressione ENTER..."; read' &
fi
