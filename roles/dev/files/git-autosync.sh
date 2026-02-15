#!/bin/bash
# ArchDev v3.0 - Git Auto-Sync Script (Robusto)
# Sincroniza repos automaticamente com proteção contra concorrência

set -uo pipefail

# ============================================
# CONFIGURAÇÃO
# ============================================

LOCK_FILE="/tmp/git-autosync.lock"
LOG_FILE="$HOME/.local/log/git-autosync.log"
MAX_RETRIES=3
RETRY_DELAY=5

# Diretório dos projetos
PROJECTS_DIR="${1:-/mnt/projetos}"

# ============================================
# FUNÇÕES
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "❌ ERRO: $1" >&2
}

success() {
    log "✅ $1"
}

info() {
    log "ℹ️  $1"
}

# Verifica se há internet (testa GitHub)
check_internet() {
    curl -s --max-time 5 https://api.github.com/zen &>/dev/null
    return $?
}

# Push com retry
push_with_retry() {
    local repo_dir="$1"
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        if check_internet; then
            if git push origin --all 2>/dev/null && git push origin --tags 2>/dev/null; then
                success "Push bem-sucedido: $repo_dir"
                return 0
            else
                error "Tentativa $attempt falhou em $repo_dir"
            fi
        else
            info "Sem internet, aguardando... ($attempt/$MAX_RETRIES)"
        fi
        
        attempt=$((attempt + 1))
        [ $attempt -le $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "Falhou após $MAX_RETRIES tentativas: $repo_dir"
    return 1
}

# ============================================
# LOCK (Evita múltiplas instâncias)
# ============================================

exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    error "Outra instância já está em execução"
    exit 1
fi

echo $$ >&200

# ============================================
# INICIALIZAÇÃO
# ============================================

# Cria diretórios necessários
mkdir -p "$(dirname "$LOG_FILE")" "$PROJECTS_DIR" 2>/dev/null || {
    error "Não foi possível criar diretórios necessários"
    exit 1
}

info "=== Git Auto-Sync iniciado ==="
info "Diretório: $PROJECTS_DIR"

# ============================================
# LOOP PRINCIPAL
# ============================================

while true; do
    # Verifica internet no início de cada ciclo
    if ! check_internet; then
        info "Sem conectividade, aguardando 5 minutos..."
        sleep 300
        continue
    fi
    
    # Contador de repos sincronizados
    SYNC_COUNT=0
    
    # Procura por repositórios git
    while IFS= read -r -d '' gitdir; do
        repo_dir=$(dirname "$gitdir")
        cd "$repo_dir" || continue
        
        # Verifica se é um repo válido
        if ! git rev-parse --git-dir &>/dev/null; then
            continue
        fi
        
        # Obtém remote info
        REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
        if [ -z "$REMOTE_URL" ]; then
            continue
        fi
        
        # Obtém branch atual
        LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        if [ -z "$LOCAL_BRANCH" ]; then
            continue
        fi
        
        # Verifica se está ahead do remote
        if git rev-parse "@{u}" &>/dev/null; then
            AHEAD_COUNT=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
            BEHIND_COUNT=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
            
            # Se está behind (precisa de pull primeiro), avisa mas não faz nada
            if [ "$BEHIND_COUNT" -gt 0 ]; then
                info "⚠️  $repo_dir está $BEHIND_COUNT commits behind - precisa de pull manual"
                continue
            fi
            
            # Se está ahead, faz push
            if [ "$AHEAD_COUNT" -gt 0 ]; then
                info "Push pendente em $repo_dir ($AHEAD_COUNT commits)"
                if push_with_retry "$repo_dir"; then
                    SYNC_COUNT=$((SYNC_COUNT + 1))
                fi
            fi
        else
            # Branch não tracking, verifica se há commits
            COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
            if [ "$COMMIT_COUNT" -gt 0 ]; then
                info "Branch não rastreada em $repo_dir - ignorando (configure upstream)"
            fi
        fi
        
    done < <(find "$PROJECTS_DIR" -maxdepth 2 -type d -name ".git" -print0 2>/dev/null)
    
    if [ $SYNC_COUNT -gt 0 ]; then
        success "Ciclo completo: $SYNC_COUNT repositório(s) sincronizado(s)"
    fi
    
    info "Próxima verificação em 5 minutos..."
    sleep 300
done
