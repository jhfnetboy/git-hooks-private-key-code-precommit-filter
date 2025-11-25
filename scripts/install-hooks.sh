#!/bin/bash

##############################################################################
# Git Hooks Installer
# 
# 这个脚本将安全检查 hooks 安装到当前 git repository
# 使用方法：./install-hooks.sh
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo -e "${BLUE}🔒 Git Hooks Security Installer${NC}\n"

# 检查是否在 git repository 中
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    echo -e "${YELLOW}Please run this script from within a git repository${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing security hooks...${NC}\n"

# 备份现有的 pre-commit hook（如果存在）
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    BACKUP_FILE="$HOOKS_DIR/pre-commit.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}⚠️  Existing pre-commit hook found${NC}"
    echo -e "${YELLOW}   Backing up to: ${BACKUP_FILE}${NC}\n"
    cp "$HOOKS_DIR/pre-commit" "$BACKUP_FILE"
fi

# 复制 pre-commit hook
if [ -f "$PROJECT_ROOT/.git/hooks/pre-commit" ]; then
    # 如果当前项目已经有 pre-commit，使用它
    echo -e "${GREEN}✅ Using existing pre-commit hook from current project${NC}"
elif [ -f "$SCRIPT_DIR/../.githooks/pre-commit" ]; then
    # 从 .githooks 目录复制
    cp "$SCRIPT_DIR/../.githooks/pre-commit" "$HOOKS_DIR/pre-commit"
    echo -e "${GREEN}✅ Copied pre-commit hook from .githooks${NC}"
else
    echo -e "${RED}❌ Error: pre-commit hook not found${NC}"
    echo -e "${YELLOW}Please ensure the hook file exists${NC}"
    exit 1
fi

# 确保 hook 可执行
chmod +x "$HOOKS_DIR/pre-commit"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Security hooks installed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}🔍 What's protected:${NC}"
echo -e "  • Ethereum private keys (0x + 64 hex)"
echo -e "  • PEM format private keys"
echo -e "  • AWS access/secret keys"
echo -e "  • Other sensitive credentials\n"

echo -e "${BLUE}📝 Next steps:${NC}"
echo -e "  1. Try committing - hooks will automatically check for secrets"
echo -e "  2. If you need to bypass (NOT recommended): ${YELLOW}git commit --no-verify${NC}"
echo -e "  3. Keep your .env files in .gitignore\n"

echo -e "${BLUE}🚀 You're all set!${NC}\n"

exit 0
