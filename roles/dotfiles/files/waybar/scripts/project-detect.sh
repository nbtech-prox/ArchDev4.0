#!/usr/bin/env bash
# ArchDev v3.0 - Detecção Inteligente de Projetos (Melhorada)
# Waybar custom module - retorna tipo de projeto e versão

set -uo pipefail

# ============================================
# 0. DEPENDÊNCIAS
# ============================================

command -v hyprctl &>/dev/null || exit 0
if ! command -v jq &>/dev/null; then
    echo "⚠️ jq não instalado"
    exit 0
fi

# ============================================
# 1. CACHE (evita spam ao hyprctl)
# ============================================

CACHE_FILE="/tmp/waybar-project-detect.cache"
CACHE_TTL=2  # segundos

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE" 2>/dev/null
        exit 0
    fi
fi

# ============================================
# 2. OBTÉM JANELA ATIVA COM VALIDAÇÃO
# ============================================

ACTIVE=$(hyprctl activewindow -j 2>/dev/null)

# Valida JSON
if ! echo "$ACTIVE" | jq -e . &>/dev/null; then
    exit 0
fi

# Extrai e valida PID (deve ser número inteiro positivo)
PID=$(echo "$ACTIVE" | jq -r '.pid // empty')
if [[ -z "$PID" || "$PID" == "null" || ! "$PID" =~ ^[0-9]+$ ]]; then
    exit 0
fi

# Verifica se processo existe (evita race condition)
if ! kill -0 "$PID" 2>/dev/null; then
    exit 0
fi

# ============================================
# 3. OBTÉM DIRETÓRIO DE TRABALHO
# ============================================

CWD=""
if [[ -r "/proc/$PID/cwd" ]]; then
    CWD=$(readlink -f "/proc/$PID/cwd" 2>/dev/null)
fi

# Fallback: tenta pelo título da janela (útil para terminais)
if [[ -z "$CWD" || ! -d "$CWD" ]]; then
    # Tenta extrair do título (ex: "user@host:~/projeto")
    WINDOW_TITLE=$(echo "$ACTIVE" | jq -r '.title // empty')
    if [[ "$WINDOW_TITLE" =~ :~?(/[^$]+) ]]; then
        POSSIBLE_PATH="${BASH_REMATCH[1]}"
        POSSIBLE_PATH="${POSSIBLE_PATH/#\~/$HOME}"
        [[ -d "$POSSIBLE_PATH" ]] && CWD="$POSSIBLE_PATH"
    fi
fi

# Fallback final: diretório home
[[ -z "$CWD" || ! -d "$CWD" ]] && CWD="$HOME"

# ============================================
# 4. DETEÇÃO DE PROJETO
# ============================================

PROJECT=""
ICON=""
ENV_INFO=""

# Função auxiliar para verificar ficheiros
check_files() {
    local dir="$1"
    shift
    for file in "$@"; do
        [[ -f "$dir/$file" ]] && return 0
    done
    return 1
}

# Detecção por prioridade
if check_files "$CWD" "artisan" "../artisan"; then
    ICON=""
    PROJECT="Laravel"
elif check_files "$CWD" "Cargo.toml"; then
    ICON=""
    PROJECT="Rust"
elif check_files "$CWD" "go.mod"; then
    ICON=""
    PROJECT="Go"
elif check_files "$CWD" "package.json"; then
    ICON=""
    PROJECT="NodeJS"
elif check_files "$CWD" "requirements.txt" "pyproject.toml" "setup.py" "app.py" "main.py"; then
    ICON=""
    PROJECT="Python"
elif check_files "$CWD" "composer.json"; then
    ICON=""
    PROJECT="PHP"
elif check_files "$CWD" ".tool-versions"; then
    ICON=""
    PROJECT="ASDF"
fi

# ============================================
# 5. BUSCA VERSÃO (.tool-versions)
# ============================================

SEARCH_DIR="$CWD"
for _ in {1..3}; do
    if [[ -f "$SEARCH_DIR/.tool-versions" ]]; then
        # Pega a primeira linha (linguagem principal)
        VERSION=$(head -n 1 "$SEARCH_DIR/.tool-versions" 2>/dev/null | awk '{print $NF}')
        if [[ -n "$VERSION" && "$VERSION" != "system" ]]; then
            ENV_INFO="($VERSION)"
        fi
        break
    fi
    SEARCH_DIR=$(dirname "$SEARCH_DIR")
    [[ "$SEARCH_DIR" == "/" ]] && break
done

# ============================================
# 6. FALLBACKS DE VERSÃO
# ============================================

if [[ -z "$ENV_INFO" ]]; then
    case "$PROJECT" in
        "Laravel"|"PHP")
            if command -v php &>/dev/null; then
                PHP_V=$(php -v 2>/dev/null | head -n 1 | awk '{print $2}' | cut -d. -f1,2)
                [[ -n "$PHP_V" ]] && ENV_INFO="($PHP_V)"
            fi
            ;;
        "NodeJS")
            if [[ -f "$CWD/package.json" ]]; then
                # Tenta pegar versão do Node do package.json engines
                NODE_V=$(jq -r '.engines.node // empty' "$CWD/package.json" 2>/dev/null)
                [[ -n "$NODE_V" ]] && ENV_INFO="($NODE_V)"
            fi
            ;;
        "Python")
            if [[ -f "$CWD/pyproject.toml" ]]; then
                # Tenta pegar versão do Poetry
                PY_V=$(grep -m1 'python = ' "$CWD/pyproject.toml" 2>/dev/null | sed 's/.*"\^*\(.*\)".*/\1/')
                [[ -n "$PY_V" ]] && ENV_INFO="($PY_V)"
            fi
            ;;
        "Rust")
            if command -v rustc &>/dev/null; then
                RUST_V=$(rustc --version 2>/dev/null | awk '{print $2}')
                [[ -n "$RUST_V" ]] && ENV_INFO="($RUST_V)"
            fi
            ;;
    esac
fi

# ============================================
# 7. INDICADORES EXTRAS
# ============================================

# Direnv ativo (procura em 2 níveis)
if [[ -d "$CWD/.direnv" || -d "$CWD/../.direnv" ]]; then
    ENV_INFO="$ENV_INFO "
fi

# Docker no projeto
if [[ -f "$CWD/docker-compose.yml" || -f "$CWD/Dockerfile" ]]; then
    ENV_INFO="$ENV_INFO "
fi

# Git repo (mostra branch se dirty)
if [[ -d "$CWD/.git" ]]; then
    cd "$CWD" || exit 1
    if git rev-parse --git-dir &>/dev/null; then
        GIT_BRANCH=$(git branch --show-current 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "detached")
        if [[ -n "$GIT_BRANCH" ]]; then
            # Verifica se há mudanças não commitadas
            if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
                GIT_BRANCH="$GIT_BRANCH*"
            fi
            ENV_INFO="$ENV_INFO 󰊢 $GIT_BRANCH"
        fi
    fi
fi

# ============================================
# 8. OUTPUT
# ============================================

[[ -z "$PROJECT" && -z "$ENV_INFO" ]] && exit 0
[[ -z "$PROJECT" ]] && PROJECT="Projeto"

OUTPUT="$ICON $PROJECT $ENV_INFO"

# Guarda cache e imprime
echo "$OUTPUT" | tee "$CACHE_FILE" 2>/dev/null
