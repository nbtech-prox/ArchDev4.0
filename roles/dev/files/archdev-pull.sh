#!/bin/bash
# ArchDev 4.0 - GitOps Pull & provision

set -uo pipefail

# ============================================
# CONFIGURAÇÃO
# ============================================

LOCK_FILE="/tmp/archdev-pull.lock"
LOG_FILE="$HOME/.local/log/archdev-pull.log"
ARCHDEV_REPO="${1:-$HOME/ArchDev}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verifica se há internet (via Github Actions/API)
check_internet() {
    curl -s --max-time 5 https://api.github.com/zen &>/dev/null
    return $?
}

# ============================================
# LOCK (Evita múltiplas instâncias)
# ============================================

exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    exit 1
fi

echo $$ >&200

# ============================================
# EXECUÇÃO GITOPS
# ============================================

if ! check_internet; then
    log "ℹ️ Sem conectividade. Cancelando ArchDev Pull."
    exit 0
fi

if [ ! -d "$ARCHDEV_REPO/.git" ]; then
    log "❌ ERRO: $ARCHDEV_REPO não é um repositório Git válido."
    exit 1
fi

cd "$ARCHDEV_REPO" || exit 1

# Fetch changes do origin
git fetch origin main -q

# Verificar se a HEAD local difere da origin/main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    log "🔄 Diferenças detetadas! Aplicando atualizações GitOps..."
    
    # Fazemos um merge fast-forward
    if git merge origin/main --ff-only -q; then
        log "✅ Pull concluído com sucesso. Iniciando Ansible (GitOps)..."
        
        # Corremos a nossa própria stack via sudo timeout pass-through ou expect no futuro.
        # Por segurança num self-apply de background limitamo-nos ao dev e interface gráfica
        # NOTA: -K exige sudo, mas vamos correr com sudo pass já validado no background
        
        # Como o playbooks/site.yml pede SUDO, idealmente isto correria no Nível Root
        # Se for root, as pastas ficam com dono Root (não ideal).
        # Implementação Futura: systemd a correr como user mas usando visudo NOPASSWD para ansible-playbook.
        
        log "⚠️ Ansible play em background requer NOPASSWD no visudo. A executar notify-send!"
        notify-send -u normal "ArchDev 4.0 GitOps" "Código atualizado com sucesso! Execute ./setup.sh para aplicar."
    else
        log "❌ ERRO: Conflito no merge. O GitOps requer um repositório clean."
        notify-send -u critical "ArchDev GitOps Falhou" "Conflito detetado no merge. Por favor repare o repositório manualmente."
    fi
else
    log "✅ Sistema sincronizado. Nenhuma alteração GitOps necessária."
fi
