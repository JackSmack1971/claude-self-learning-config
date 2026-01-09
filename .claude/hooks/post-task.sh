#!/bin/bash
# Post-Task Lifecycle Hook
# Triggers after successful task completion
# Purpose: Automatically sync memory bank with learnings from completed task

set -e

# Configuration
CLAUDE_DIR=".claude"
MEMORY_BANK_DIR="$CLAUDE_DIR/memory-bank"
AUDIT_LOG="$CLAUDE_DIR/audit-log/$(date +%Y-%m-%d).log"
BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y-%m-%d_%H%M%S)"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$AUDIT_LOG"
}

# Check if task was successful
if [ "$TASK_STATUS" != "success" ]; then
    log "Task not successful, skipping memory sync"
    exit 0
fi

log "=== Post-Task Hook Started ==="
log "Task: $TASK_NAME"
log "Status: $TASK_STATUS"

# Create backup before modifications
log "Creating backup..."
mkdir -p "$BACKUP_DIR"
cp -r "$MEMORY_BANK_DIR" "$BACKUP_DIR/"
log "Backup created at: $BACKUP_DIR"

# Extract task summary and context
TASK_CONTEXT="${TASK_SUMMARY:-No summary provided}"
GIT_RANGE="${LAST_SYNC_COMMIT:-HEAD~1}..HEAD"

log "Analyzing changes in git range: $GIT_RANGE"

# Check if there are meaningful code changes
CHANGES=$(git diff "$GIT_RANGE" --stat | wc -l)
if [ "$CHANGES" -lt 3 ]; then
    log "Minimal changes detected, skipping sync"
    exit 0
fi

# Invoke memory bank synchronizer agent
log "Invoking memory-bank-synchronizer agent..."

# Create temporary context file for the agent
CONTEXT_FILE="/tmp/claude-sync-context-$$.json"
cat > "$CONTEXT_FILE" <<EOF
{
  "mode": "auto",
  "trigger": "post-task-hook",
  "task_name": "$TASK_NAME",
  "task_status": "$TASK_STATUS",
  "task_summary": "$TASK_CONTEXT",
  "git_range": "$GIT_RANGE",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "changes_count": $CHANGES
}
EOF

# Execute synchronization (this would call Claude with the agent)
# In practice, this might use Claude CLI or API
if command -v claude &> /dev/null; then
    log "Running memory synchronization..."
    
    # Invoke Claude with memory-bank-synchronizer agent
    claude invoke-agent \
        --agent="memory-bank-synchronizer" \
        --context="$CONTEXT_FILE" \
        --mode="auto" \
        --output="$CLAUDE_DIR/logs/sync-$(date +%Y%m%d-%H%M%S).log"
    
    SYNC_STATUS=$?
    
    if [ $SYNC_STATUS -eq 0 ]; then
        log "✅ Memory synchronization completed successfully"
        
        # Update last sync marker
        git tag -f "memory-sync-$(date +%Y%m%d)" HEAD
        echo "$(git rev-parse HEAD)" > "$CLAUDE_DIR/.last-sync-commit"
        
    else
        log "❌ Memory synchronization failed with status: $SYNC_STATUS"
        log "Backup available at: $BACKUP_DIR"
    fi
else
    log "⚠️  Claude CLI not found, skipping automatic sync"
    log "Run manually: claude /sync-memory"
fi

# Cleanup
rm -f "$CONTEXT_FILE"

# Generate TODO summary if new TODOs were added
NEW_TODOS=$(git diff "$GIT_RANGE" | grep -c "^\+.*TODO" || true)
if [ "$NEW_TODOS" -gt 0 ]; then
    log "📝 Detected $NEW_TODOS new TODO items"
    
    # Extract TODOs and log them
    git diff "$GIT_RANGE" | grep "^\+.*TODO" | sed 's/^\+//' > "$CLAUDE_DIR/logs/todos-$(date +%Y%m%d).txt"
    log "TODOs logged to: $CLAUDE_DIR/logs/todos-$(date +%Y%m%d).txt"
fi

# Update activity log
ACTIVITY_LOG="$CLAUDE_DIR/activity-log.md"
cat >> "$ACTIVITY_LOG" <<EOF

## $(date +'%Y-%m-%d %H:%M:%S') - $TASK_NAME
- **Status**: $TASK_STATUS ✅
- **Changes**: $CHANGES files modified
- **New TODOs**: $NEW_TODOS
- **Sync**: Completed
- **Backup**: $BACKUP_DIR

EOF

log "=== Post-Task Hook Completed ==="
log "Activity logged to: $ACTIVITY_LOG"

exit 0
