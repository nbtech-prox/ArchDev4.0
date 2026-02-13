<?php
/**
 * ArchDev 3.0 - phpMyAdmin Configuration
 * 
 * Esta configuração usa autenticação por cookie com suporte a Unix socket
 * para conexão segura com MariaDB.
 */

// Verbose name para o servidor
$cfg['Servers'][$i]['verbose'] = 'ArchDev Local';

// Autenticação
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowNoPassword'] = false;

// Conexão via Unix Socket (mais seguro e rápido)
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['connect_type'] = 'socket';
$cfg['Servers'][$i]['socket'] = '/run/mysqld/mysqld.sock';

// Compressão
$cfg['Servers'][$i]['compress'] = true;

// SSL (desativado para desenvolvimento local)
$cfg['Servers'][$i]['ssl'] = false;

// Allow root login (necessário para configuração inicial)
$cfg['Servers'][$i]['AllowRoot'] = true;

// Blowfish secret - Será substituído automaticamente pelo Ansible
$cfg['blowfish_secret'] = 'ARCHDEV_REPLACE_ME_WITH_RANDOM_STRING_32CH';

// Diretórios para salvar/导入 arquivos
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

// Temp directory
$cfg['TempDir'] = '/tmp';

// Mostrar erros de PHP (desativar em produção)
$cfg['SendErrorReports'] = 'never';

// Layout padrão
$cfg['DefaultLang'] = 'pt';
$cfg['ServerDefault'] = 1;

// Tema padrão (compatível com Catppuccin)
$cfg['ThemeDefault'] = 'pmahomme';

// Numero de registros por página
$cfg['MaxRows'] = 50;

// Confirmar DROP/DELETE
$cfg['Confirm'] = true;

// Modo de edição de registros
$cfg['RowActionType'] = 'both';

// Navegação
$cfg['ShowAll'] = false;
$cfg['MaxExactCount'] = 20000;
$cfg['MaxExactCountViews'] = 1000;
$cfg['QueryHistoryMax'] = 25;

// Exportação padrão
$cfg['Export']['format'] = 'sql';
$cfg['Export']['compression'] = 'gzip';

// Codificação
$cfg['DefaultCharset'] = 'utf8mb4';
$cfg['DefaultCollation'] = 'utf8mb4_general_ci';
