#!/bin/bash

##############################################################################
# Git Hooks Security Installer
# 
# Install security hooks to the current git repository
# Usage: 
#   curl -fsSL https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/scripts/install-hooks.sh | bash
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_URL="https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main"

echo -e "${BLUE}🔒 Git Hooks Security Installer${NC}\n"

# Check if inside a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    echo -e "${YELLOW}Please run this script from the root of your git repository${NC}"
    exit 1
fi

HOOKS_DIR=".git/hooks"
WORKFLOW_DIR=".github/workflows"

echo -e "${BLUE}📦 Installing security components...${NC}\n"

# 1. Install Pre-commit Hook
echo -e "1️⃣  Installing pre-commit hook..."

# Backup existing hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    BACKUP_FILE="$HOOKS_DIR/pre-commit.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}   ⚠️  Backing up existing hook to: $(basename $BACKUP_FILE)${NC}"
    cp "$HOOKS_DIR/pre-commit" "$BACKUP_FILE"
fi

# Download hook
curl -fsSL "$REPO_URL/hooks/pre-commit" -o "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo -e "${GREEN}   ✅ Pre-commit hook installed${NC}\n"

# 2. Install GitHub Actions Workflow
echo -e "2️⃣  Installing GitHub Actions workflow..."

mkdir -p "$WORKFLOW_DIR"
WORKFLOW_FILE="$WORKFLOW_DIR/check-secrets.yml"

# Backup existing workflow
if [ -f "$WORKFLOW_FILE" ]; then
    BACKUP_WORKFLOW="$WORKFLOW_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}   ⚠️  Backing up existing workflow to: $(basename $BACKUP_WORKFLOW)${NC}"
    cp "$WORKFLOW_FILE" "$BACKUP_WORKFLOW"
fi

# Download workflow
curl -fsSL "$REPO_URL/.github/workflows/check-secrets.yml" -o "$WORKFLOW_FILE"
echo -e "${GREEN}   ✅ GitHub Actions workflow installed${NC}\n"

# 3. Setup Environment
echo -e "3️⃣  Checking environment configuration..."

# Check .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" ".gitignore"; then
        echo -e "${YELLOW}   ⚠️  Adding .env to .gitignore${NC}"
        echo "" >> ".gitignore"
        echo "# Environment variables" >> ".gitignore"
        echo ".env" >> ".gitignore"
    else
        echo -e "${GREEN}   ✅ .env is already ignored${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  No .gitignore found${NC}"
fi

# Create .env.example if missing
if [ ! -f ".env.example" ]; then
    cat > ".env.example" << 'EOF'
# Environment Variables Template
# Copy this file to .env and fill in your values
# NEVER commit .env file to git!

PRIVATE_KEY=
API_KEY=
EOF
    echo -e "${GREEN}   ✅ Created .env.example template${NC}\n"
else
    echo -e "${GREEN}   ✅ .env.example already exists${NC}\n"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}🔍 Protected against:${NC}"
echo -e "  • Ethereum & PEM Private Keys"
echo -e "  • AWS, OpenAI, Google, Anthropic Keys"
echo -e "  • GitHub Tokens & Stripe Keys\n"

echo -e "${BLUE}📝 Next steps:${NC}"
echo -e "  1. Test with: ${GREEN}git commit${NC}"
echo -e "  2. Push to enable GitHub Actions checks\n"

exit 0
