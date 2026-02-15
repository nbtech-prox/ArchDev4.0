#!/bin/bash
# ArchDev v3.0 - Waybar Update Notifier (Corrigido)
# Mostra notificação e abre terminal para atualizar quando clicado
# Agora inclui OFICIAIS + AUR (consistente com updates.sh)

# ============================================
# 1. CONTA ATUALIZAÇÕES (Oficiais + AUR)
# ============================================

# Atualizações oficiais
OFFICIAL=$(checkupdates 2>/dev/null | wc -l | xargs)

# Atualizações AUR (se yay estiver instalado)
AUR=0
if command -v yay &> /dev/null; then
    AUR=$(yay -Qum 2>/dev/null | wc -l | xargs)
fi

# Total
UPDATES=$((OFFICIAL + AUR))

# ============================================
# 2. OUTPUT PARA WAYBAR
# ============================================

if [ "$UPDATES" -eq 0 ]; then
    echo ""
    exit 0
else
    echo " $UPDATES"
fi

# ============================================
# 3. QUANDO CLICADO - MOSTRA NOTIFICAÇÃO
# ============================================

if [ "$1" == "click" ]; then
    # Prepara detalhes
    DETAILS=""
    
    # Adiciona oficiais
    if [ "$OFFICIAL" -gt 0 ]; then
        OFFICIAL_LIST=$(checkupdates 2>/dev/null | head -5)
        DETAILS+="📦 Oficiais ($OFFICIAL):"
        DETAILS+="\n$OFFICIAL_LIST"
        if [ "$OFFICIAL" -gt 5 ]; then
            DETAILS+="\n... e mais $((OFFICIAL - 5)) pacotes"
        fi
        DETAILS+="\n\n"
    fi
    
    # Adiciona AUR
    if [ "$AUR" -gt 0 ]; then
        AUR_LIST=$(yay -Qum 2>/dev/null | head -5)
        DETAILS+="🎨 AUR ($AUR):"
        DETAILS+="\n$AUR_LIST"
        if [ "$AUR" -gt 5 ]; then
            DETAILS+="\n... e mais $((AUR - 5)) pacotes"
        fi
    fi
    
    # Notificação
    dunstify -a "Waybar Updates" \
             -u normal \
             -r 9991 \
             "📦 $UPDATES atualizações disponíveis" \
             "$DETAILS" \
             -a "Clique para atualizar"
    
    # Abre kitty com yay
    kitty -e sh -c 'echo "📦 Atualizando sistema..."; yay -Syu; echo "✅ Concluído! Pressione ENTER..."; read' &
fi
