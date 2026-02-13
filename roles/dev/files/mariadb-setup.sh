#!/bin/bash
# ArchDev 3.0 - MariaDB Setup Helper
# Script para configurar MariaDB de forma segura

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 ArchDev MariaDB Setup${NC}"
echo "=========================================="

# Verifica se o MariaDB está instalado
if ! command -v mariadb &> /dev/null; then
    echo -e "${RED}❌ MariaDB não está instalado.${NC}"
    echo "   Execute o setup.sh primeiro."
    exit 1
fi

# Verifica se o serviço está ativo
if ! systemctl is-active --quiet mariadb; then
    echo -e "${YELLOW}⚠️  Iniciando MariaDB...${NC}"
    sudo systemctl start mariadb
fi

echo -e "${GREEN}✅ MariaDB está ativo${NC}"
echo ""

# Verifica se já foi configurado (root com password)
echo -e "${BLUE}🔐 Configuração de Segurança${NC}"
echo "=========================================="
echo ""
echo "Este script vai configurar o MariaDB com:"
echo "  • Password para root"
echo "  • Remover usuários anónimos"
echo "  • Remover base de dados de teste"
echo "  • Desativar login root remoto"
echo ""
echo -e "${YELLOW}Pressione ENTER para continuar ou Ctrl+C para cancelar...${NC}"
read

# Executa o secure installation de forma automática
echo -e "${BLUE}⚡ A executar configuração segura...${NC}"

# Gera password aleatória para root
ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-16)

echo ""
echo -e "${YELLOW}📝 Password gerada para root: ${NC}${GREEN}${ROOT_PASSWORD}${NC}"
echo ""

# Configuração automática do MariaDB
sudo mysql -sfu root <<EOSQL
-- Remove anonymous users
DELETE FROM mysql.global_priv WHERE User='';

-- Remove remote root access
DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

-- Reload privileges
FLUSH PRIVILEGES;
EOSQL

# Salva as credenciais num arquivo
CREDENTIALS_FILE="${HOME}/.config/archdev/mariadb-credentials.txt"
mkdir -p "$(dirname ${CREDENTIALS_FILE})"

cat > "${CREDENTIALS_FILE}" <<EOF
========================================
🗄️  MariaDB Credentials - ArchDev 3.0
========================================

Host:     localhost
Port:     3306
User:     root
Password: ${ROOT_PASSWORD}

phpMyAdmin: http://localhost/phpmyadmin

⚠️  GUARDE ESTE ARQUIVO EM LOCAL SEGURO!
    E apague-o depois de memorizar a password.

========================================
EOF

chmod 600 "${CREDENTIALS_FILE}"

echo ""
echo -e "${GREEN}✅ MariaDB configurado com sucesso!${NC}"
echo ""
echo -e "${BLUE}📋 Resumo:${NC}"
echo "  • Password root: ${GREEN}${ROOT_PASSWORD}${NC}"
echo "  • Credenciais salvas em: ${YELLOW}${CREDENTIALS_FILE}${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "   Guarde a password e apague o arquivo de credenciais!"
echo ""
echo "   Teste a ligação:"
echo -e "   ${BLUE}mariadb -u root -p${NC}"
echo ""
