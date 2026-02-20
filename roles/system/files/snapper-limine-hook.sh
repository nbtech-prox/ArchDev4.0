#!/bin/bash
# Snapper hook - Atualiza menu Limine após criar/apagar snapshot
# Colocar em: /etc/snapper/hooks/limine-sync.sh

/usr/local/bin/generate-limine-snapshots.sh >/dev/null 2>&1
exit 0
