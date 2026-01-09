#!/bin/bash
# Quick Setup Script for Self-Learning Claude Configuration
# Version: 1.0.0
# Usage: ./setup.sh [project-directory]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="${1:-.}"
CLAUDE_DIR="$PROJECT_DIR/.claude"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Self-Learning Claude Configuration Setup              ║${NC}"
echo -e "${BLUE}║   Version 1.0.0                                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Claude CLI not found${NC}"
    echo "   Some features require Claude Code v2.1.0+"
    echo "   Continue anyway? [y/N]"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if directory already has .claude
if [ -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}⚠️  .claude directory already exists${NC}"
    echo "   Backup and overwrite? [y/N]"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$PROJECT_DIR/.claude.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}📦 Creating backup at: $BACKUP_DIR${NC}"
        mv "$CLAUDE_DIR" "$BACKUP_DIR"
    else
        echo -e "${RED}❌ Setup cancelled${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}🚀 Setting up self-learning Claude configuration...${NC}"
echo ""

# Create directory structure
echo -e "${BLUE}📁 Creating directory structure...${NC}"
mkdir -p "$CLAUDE_DIR"/{memory-bank,agents,skills,rules,hooks,logs,backups,audit-log,examples}
mkdir -p "$CLAUDE_DIR"/rules/{backend,frontend,tests,api}

# Copy or create memory bank files
echo -e "${BLUE}📝 Creating memory bank files...${NC}"

cat > "$CLAUDE_DIR/memory-bank/CLAUDE-patterns.md" <<'EOF'
# Coding Patterns Library
**Last Updated**: $(date +%Y-%m-%d)
**Auto-Sync**: Enabled

## 📐 Pattern Template
Use this template when documenting new patterns.

## 🎯 Active Patterns
*Patterns will be added as they are discovered*

## 📊 Pattern Usage Statistics
*Auto-updated during sync*
EOF

cat > "$CLAUDE_DIR/memory-bank/CLAUDE-decisions.md" <<'EOF'
# Architectural Decisions Log (ADL)
**Last Updated**: $(date +%Y-%m-%d)

## 📋 Decision Template
Use this template for architectural decisions.

## 🎯 Active Decisions
*Decisions will be logged here*
EOF

cat > "$CLAUDE_DIR/memory-bank/CLAUDE-troubleshooting.md" <<'EOF'
# Troubleshooting Knowledge Base
**Last Updated**: $(date +%Y-%m-%d)

## 🔧 Issue Template
Use this template for troubleshooting entries.

## 🚨 Critical Issues
*Issues and solutions will be documented here*
EOF

cat > "$CLAUDE_DIR/memory-bank/CLAUDE-snippets.md" <<'EOF'
# Code Snippets Library
**Last Updated**: $(date +%Y-%m-%d)

## 📋 Snippet Template
Reusable code patterns with examples.

## 🎯 Active Snippets
*Snippets will be added as patterns are implemented*
EOF

cat > "$CLAUDE_DIR/memory-bank/CLAUDE-metrics.md" <<'EOF'
# Performance Metrics & Learning Analytics
**Last Updated**: $(date +%Y-%m-%d)

## 📊 Current Status
Token Budget: 0/200 (Healthy ✅)

## 📈 Learning Velocity
*Metrics will be tracked automatically*
EOF

# Create main configuration file
echo -e "${BLUE}⚙️  Creating main configuration...${NC}"

cat > "$CLAUDE_DIR/CLAUDE.md" <<'EOF'
# Self-Learning Claude Configuration
**Version**: 1.0.0

## 🎯 Quick Commands
- Press `#` to capture patterns in real-time
- `/sync-memory` - Sync memory bank with codebase
- `/cleanup-context` - Optimize token budget
- `/memory-report` - View learning statistics

## 📚 Memory Bank
This configuration uses a modular memory bank system:
- `CLAUDE-patterns.md` - Coding patterns
- `CLAUDE-decisions.md` - Architectural decisions
- `CLAUDE-troubleshooting.md` - Known issues
- `CLAUDE-snippets.md` - Code snippets
- `CLAUDE-metrics.md` - Performance tracking

## 🚀 Getting Started
1. Start coding
2. Press `#` when you discover useful patterns
3. Run `/sync-memory` after tasks
4. Review and commit changes

See README.md for full documentation.
EOF

# Create hooks
echo -e "${BLUE}🎣 Setting up lifecycle hooks...${NC}"

cat > "$CLAUDE_DIR/hooks/post-task.sh" <<'HOOKEOF'
#!/bin/bash
# Post-Task Hook - Auto-sync memory bank after successful tasks
set -e

if [ "$TASK_STATUS" = "success" ]; then
    echo "📝 Auto-syncing memory bank..."
    # Add your sync logic here
    echo "✅ Memory sync complete"
fi
HOOKEOF

chmod +x "$CLAUDE_DIR/hooks/post-task.sh"

# Create placeholder files
echo -e "${BLUE}📄 Creating placeholder files...${NC}"
touch "$CLAUDE_DIR/logs/.gitkeep"
touch "$CLAUDE_DIR/backups/.gitkeep"
touch "$CLAUDE_DIR/audit-log/.gitkeep"

# Create .gitignore
cat > "$CLAUDE_DIR/.gitignore" <<'EOF'
# Logs and temporary files
logs/*.log
logs/sync-*.log
logs/cleanup-*.log
audit-log/*.log

# Backups (can be large)
backups/*/

# Temporary files
*.tmp
.DS_Store

# Keep directory structure
!logs/.gitkeep
!backups/.gitkeep
!audit-log/.gitkeep
EOF

# Initialize git if not already
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo -e "${BLUE}🔧 Initializing git repository...${NC}"
    cd "$PROJECT_DIR"
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# Create initial commit
echo -e "${BLUE}💾 Creating initial commit...${NC}"
cd "$PROJECT_DIR"
git add .claude/
git commit -m "Initial self-learning Claude configuration setup" || echo "Note: Files may already be committed"

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Setup Complete!                                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📁 Configuration created at:${NC} $CLAUDE_DIR"
echo ""
echo -e "${YELLOW}🎓 Next Steps:${NC}"
echo "   1. Review the README.md for full documentation"
echo "   2. Start coding and press '#' to capture patterns"
echo "   3. Run 'claude /sync-memory' after tasks"
echo "   4. Run 'claude /memory-report' to see what was learned"
echo ""
echo -e "${BLUE}📚 Key Files:${NC}"
echo "   • .claude/CLAUDE.md - Main configuration"
echo "   • .claude/memory-bank/ - Living memory bank"
echo "   • .claude/hooks/ - Automation scripts"
echo ""
echo -e "${GREEN}Happy learning! 🚀${NC}"
echo ""

# Optional: Display directory tree
if command -v tree &> /dev/null; then
    echo -e "${BLUE}📊 Directory Structure:${NC}"
    tree -L 3 -I 'node_modules|dist|build' "$CLAUDE_DIR"
fi
