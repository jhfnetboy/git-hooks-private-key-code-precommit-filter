#!/bin/bash

##############################################################################
# 一键部署安全检查到其他项目
# 
# 使用方法：
#   ./deploy-to-project.sh /path/to/target/project
#
# 这个脚本会：
#   1. 复制 pre-commit hook
#   2. 复制 GitHub Actions workflow
#   3. 自动安装和配置
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PROJECT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: No target project specified${NC}\n"
    echo -e "Usage: $0 /path/to/target/project\n"
    echo -e "Example:"
    echo -e "  $0 ~/projects/my-other-repo"
    exit 1
fi

TARGET_PROJECT="$1"

# 验证目标项目
if [ ! -d "$TARGET_PROJECT" ]; then
    echo -e "${RED}❌ Error: Target directory does not exist: $TARGET_PROJECT${NC}"
    exit 1
fi

if [ ! -d "$TARGET_PROJECT/.git" ]; then
    echo -e "${RED}❌ Error: Target is not a git repository: $TARGET_PROJECT${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Deploying Security Hooks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Source:${NC} $SOURCE_PROJECT"
echo -e "${BLUE}Target:${NC} $TARGET_PROJECT"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 1. 复制 pre-commit hook
echo -e "${BLUE}📦 Step 1: Installing Git Hook...${NC}"

TARGET_HOOKS_DIR="$TARGET_PROJECT/.git/hooks"
SOURCE_HOOK="$SOURCE_PROJECT/.git/hooks/pre-commit"

if [ ! -f "$SOURCE_HOOK" ]; then
    echo -e "${RED}❌ Error: Source pre-commit hook not found${NC}"
    exit 1
fi

# 备份现有 hook
if [ -f "$TARGET_HOOKS_DIR/pre-commit" ]; then
    BACKUP_FILE="$TARGET_HOOKS_DIR/pre-commit.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}   ⚠️  Backing up existing hook to: $(basename $BACKUP_FILE)${NC}"
    cp "$TARGET_HOOKS_DIR/pre-commit" "$BACKUP_FILE"
fi

# 复制 hook
cp "$SOURCE_HOOK" "$TARGET_HOOKS_DIR/pre-commit"
chmod +x "$TARGET_HOOKS_DIR/pre-commit"
echo -e "${GREEN}   ✅ Git hook installed${NC}\n"

# 2. 复制 GitHub Actions workflow
echo -e "${BLUE}📦 Step 2: Installing GitHub Actions...${NC}"

SOURCE_WORKFLOW="$SOURCE_PROJECT/.github/workflows/check-secrets.yml"
TARGET_WORKFLOWS_DIR="$TARGET_PROJECT/.github/workflows"

if [ -f "$SOURCE_WORKFLOW" ]; then
    mkdir -p "$TARGET_WORKFLOWS_DIR"
    
    if [ -f "$TARGET_WORKFLOWS_DIR/check-secrets.yml" ]; then
        BACKUP_WORKFLOW="$TARGET_WORKFLOWS_DIR/check-secrets.yml.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}   ⚠️  Backing up existing workflow to: $(basename $BACKUP_WORKFLOW)${NC}"
        cp "$TARGET_WORKFLOWS_DIR/check-secrets.yml" "$BACKUP_WORKFLOW"
    fi
    
    cp "$SOURCE_WORKFLOW" "$TARGET_WORKFLOWS_DIR/check-secrets.yml"
    echo -e "${GREEN}   ✅ GitHub Actions workflow installed${NC}\n"
else
    echo -e "${YELLOW}   ⚠️  GitHub Actions workflow not found, skipping${NC}\n"
fi

# 3. 复制文档（可选）
echo -e "${BLUE}📦 Step 3: Copying documentation...${NC}"

TARGET_DOCS_DIR="$TARGET_PROJECT/docs"
mkdir -p "$TARGET_DOCS_DIR"

if [ -f "$SOURCE_PROJECT/docs/GIT_HOOKS_SECURITY_README.md" ]; then
    cp "$SOURCE_PROJECT/docs/GIT_HOOKS_SECURITY_README.md" "$TARGET_DOCS_DIR/"
    echo -e "${GREEN}   ✅ Documentation copied${NC}\n"
fi

# 4. 更新 .gitignore（如果需要）
echo -e "${BLUE}📦 Step 4: Checking .gitignore...${NC}"

TARGET_GITIGNORE="$TARGET_PROJECT/.gitignore"

if [ -f "$TARGET_GITIGNORE" ]; then
    if ! grep -q "^\.env$" "$TARGET_GITIGNORE"; then
        echo -e "${YELLOW}   ⚠️  Adding .env to .gitignore${NC}"
        echo "" >> "$TARGET_GITIGNORE"
        echo "# Environment variables (contains secrets)" >> "$TARGET_GITIGNORE"
        echo ".env" >> "$TARGET_GITIGNORE"
        echo -e "${GREEN}   ✅ .gitignore updated${NC}\n"
    else
        echo -e "${GREEN}   ✅ .env already in .gitignore${NC}\n"
    fi
else
    echo -e "${YELLOW}   ⚠️  No .gitignore found${NC}\n"
fi

# 5. 创建 .env.example（如果不存在）
echo -e "${BLUE}📦 Step 5: Checking .env.example...${NC}"

TARGET_ENV_EXAMPLE="$TARGET_PROJECT/.env.example"

if [ ! -f "$TARGET_ENV_EXAMPLE" ]; then
    cat > "$TARGET_ENV_EXAMPLE" << 'EOF'
# Environment Variables Template
# Copy this file to .env and fill in your values
# NEVER commit .env file to git!

# Private Keys (NEVER commit actual values!)
PRIVATE_KEY=
API_KEY=

# Add your environment variables here
EOF
    echo -e "${GREEN}   ✅ Created .env.example${NC}\n"
else
    echo -e "${GREEN}   ✅ .env.example already exists${NC}\n"
fi

# 完成
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${BLUE}📋 What was installed:${NC}"
echo -e "  ✅ Git pre-commit hook"
echo -e "  ✅ GitHub Actions workflow"
echo -e "  ✅ Documentation"
echo -e "  ✅ .gitignore check"
echo -e "  ✅ .env.example template\n"

echo -e "${BLUE}🔍 Protected against:${NC}"
echo -e "  • Ethereum private keys"
echo -e "  • PEM format keys"
echo -e "  • AWS credentials"
echo -e "  • API keys\n"

echo -e "${BLUE}📝 Next steps in target project:${NC}"
echo -e "  1. ${GREEN}cd $TARGET_PROJECT${NC}"
echo -e "  2. Test the hook: ${GREEN}git commit${NC}"
echo -e "  3. Push to GitHub to activate Actions"
echo -e "  4. Review ${BLUE}docs/GIT_HOOKS_SECURITY_README.md${NC}\n"

echo -e "${YELLOW}⚠️  Important:${NC}"
echo -e "  • Keep sensitive data in .env files"
echo -e "  • Never use ${YELLOW}--no-verify${NC} to bypass checks"
echo -e "  • Review the documentation for best practices\n"

echo -e "${GREEN}🎉 You're all set!${NC}\n"

exit 0
