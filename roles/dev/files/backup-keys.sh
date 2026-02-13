#!/bin/bash
# ArchDev - Backup de Chaves de Segurança
# Faz backup das chaves SSH e GPG para recuperação em caso de desastre

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BACKUP_DIR="$HOME/Backups/keys-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}🔐 ArchDev Keys Backup${NC}"
echo "=========================================="
echo ""

# Backup SSH Keys
if [ -d "$HOME/.ssh" ]; then
    echo -e "${YELLOW}📁 A fazer backup das chaves SSH...${NC}"
    cp -r "$HOME/.ssh" "$BACKUP_DIR/"
    chmod 600 "$BACKUP_DIR/.ssh"/* 2>/dev/null || true
    echo -e "${GREEN}✓ SSH keys backed up${NC}"
else
    echo -e "${RED}⚠ Diretório .ssh não encontrado${NC}"
fi

# Backup GPG Keys
echo ""
echo -e "${YELLOW}📁 A fazer backup das chaves GPG...${NC}"

# Lista chaves secretas
GPG_KEYS=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2)

if [ -z "$GPG_KEYS" ]; then
    echo -e "${RED}⚠ Nenhuma chave GPG encontrada${NC}"
else
    for KEY in $GPG_KEYS; do
        echo -e "  A exportar chave: ${BLUE}$KEY${NC}"
        gpg --armor --export-secret-keys "$KEY" > "$BACKUP_DIR/gpg-secret-$KEY.asc" 2>/dev/null || true
        gpg --armor --export "$KEY" > "$BACKUP_DIR/gpg-public-$KEY.asc" 2>/dev/null || true
    done
    
    # Backup do trustdb
    cp "$HOME/.gnupg/trustdb.gpg" "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ GPG keys backed up${NC}"
fi

# Backup git configs
echo ""
echo -e "${YELLOW}📁 A fazer backup das configurações Git...${NC}"
git config --global --list > "$BACKUP_DIR/git-config-global.txt" 2>/dev/null || true
cp "$HOME/.gitconfig" "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✓ Git config backed up${NC}"

# Cria README de recuperação
cat > "$BACKUP_DIR/README-RESTORE.md" << 'EOF'
# Restauração de Chaves

## SSH
```bash
# Copiar de volta
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp ssh/* ~/.ssh/
chmod 600 ~/.ssh/id_*~/.ssh/id_*.pub
```

## GPG
```bash
# Importar chaves
gpg --import gpg-public-*.asc
gpg --import gpg-secret-*.asc

# Restaurar trust
cp trustdb.gpg ~/.gnupg/

# Verificar
gpg --list-secret-keys
```

## Git
```bash
cp gitconfig ~/.gitconfig
```
EOF

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   ✔ BACKUP CONCLUÍDO!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "Local: ${YELLOW}$BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}⚠ IMPORTANTE:${NC}"
echo "   1. Copie esta pasta para um local seguro (USB, cloud cifrada)"
echo "   2. Apague o backup local após confirmar que está seguro"
echo "   3. NUNCA partilhe as chaves secretas!"
echo ""
