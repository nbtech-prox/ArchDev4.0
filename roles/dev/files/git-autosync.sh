#!/bin/bash
# --- Git Auto-Sync Script ---
# This script monitors a directory for git repositories and automatically pushes changes
# when network connectivity is available.

LOG_FILE="/var/log/git-autosync.log"
PROJECTS_DIR="$1"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if [ -z "$PROJECTS_DIR" ]; then
    PROJECTS_DIR="/mnt/projetos"
fi

# Ensure directory exists or wait for it (useful for slow mounts)
MAX_RETRIES=30
count=0
while [ ! -d "$PROJECTS_DIR" ]; do
    log "Waiting for projects directory: $PROJECTS_DIR..."
    sleep 5
    ((count++))
    if [ $count -ge $MAX_RETRIES ]; then
        log "Error: Directory $PROJECTS_DIR not found after waiting."
        exit 1
    fi
done

log "Starting Git Auto-Sync for directory: $PROJECTS_DIR"

while true; do
    # Check internet connectivity
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
        # Find all .git directories
        find "$PROJECTS_DIR" -maxdepth 2 -type d -name ".git" | while read -r gitdir; do
            repo_dir=$(dirname "$gitdir")
            cd "$repo_dir" || continue
            
            # Check for unpushed commits
            if git status -sb 2>/dev/null | grep -q "ahead"; then
                log "Pushing changes for: $repo_dir"
                git push origin --all >> "$LOG_FILE" 2>&1
                git push origin --tags >> "$LOG_FILE" 2>&1
            fi
        done
    fi
    sleep 300 # Check every 5 minutes
done
