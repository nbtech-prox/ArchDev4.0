#!/usr/bin/env bash
# ArchDev v2.6 - Detecção Inteligente de Projetos

ACTIVE=$(hyprctl activewindow -j 2>/dev/null)
PID=$(echo "$ACTIVE" | jq -r '.pid')

[[ -z "$PID" || "$PID" == "null" ]] && exit 0

CWD=$(readlink -f /proc/$PID/cwd 2>/dev/null)
[[ ! -d "$CWD" ]] && exit 0

PROJECT=""
ICON="⚙️"
ENV_INFO=""

# 1. Detecção de Tipo de Projeto
if [[ -f "$CWD/artisan" || -f "$CWD/../artisan" || -f "$CWD/teste/artisan" ]]; then
    ICON="🟥"
    PROJECT="Laravel"
elif [[ -f "$CWD/app.py" || -f "$CWD/run.py" || -f "$CWD/main.py" ]]; then
    ICON="🟦"
    PROJECT="Python"
elif [[ -f "$CWD/package.json" ]]; then
    ICON=""
    PROJECT="NodeJS"
elif [[ -f "$CWD/.tool-versions" ]]; then
    ICON="🛠️"
    PROJECT="Env"
fi

# 2. Busca Recursiva do .tool-versions (sobe até 3 níveis)
SEARCH_DIR="$CWD"
for _ in {1..3}; do
    if [[ -f "$SEARCH_DIR/.tool-versions" ]]; then
        VERSION=$(head -n 1 "$SEARCH_DIR/.tool-versions" | awk '{print $NF}')
        ENV_INFO="($VERSION)"
        break
    fi
    SEARCH_DIR=$(dirname "$SEARCH_DIR")
    [[ "$SEARCH_DIR" == "/" ]] && break
done

# 3. Fallback: Se for Laravel e não achou .tool-versions, pega a versão do PHP
if [[ "$PROJECT" == "Laravel" && -z "$ENV_INFO" ]]; then
    PHP_V=$(php -v | head -n 1 | awk '{print $2}' | cut -d. -f1,2)
    ENV_INFO="($PHP_V)"
fi

# 4. Indicador de Direnv Ativo
if [[ -d "$CWD/.direnv" || -d "$CWD/../.direnv" ]]; then
    ENV_INFO="$ENV_INFO 🫧"
fi

# Se não detectou nada relevante, sai silenciosamente
[[ -z "$PROJECT" && -z "$ENV_INFO" ]] && exit 0
[[ -z "$PROJECT" ]] && PROJECT="Projeto"

echo "$ICON $PROJECT $ENV_INFO"
