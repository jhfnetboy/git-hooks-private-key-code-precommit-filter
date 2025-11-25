# Pre-commit Hook 复用指南

## 📌 概述

本文档说明如何将当前项目的 pre-commit hook（私钥检测）复用到其他 repository 中。

当前的 pre-commit hook 位于：`.git/hooks/pre-commit`

## 🎯 三种复用方案

### 方案 1: 独立 Git Hooks 包（推荐）

创建一个独立的 repository 来管理和分发 hooks。

#### 1.1 创建 Hooks Repository

```bash
# 创建新的 repository
mkdir git-hooks-security
cd git-hooks-security
git init

# 创建目录结构
mkdir -p hooks scripts
```

#### 1.2 文件结构

```
git-hooks-security/
├── README.md
├── install.sh              # 安装脚本
├── uninstall.sh           # 卸载脚本
├── hooks/
│   └── pre-commit         # 你的 pre-commit 脚本
└── scripts/
    └── check-secrets.sh   # 可复用的检查脚本
```

#### 1.3 安装脚本示例

创建 `install.sh`:

```bash
#!/bin/bash

# 安装 git hooks 到目标项目
HOOKS_DIR=".git/hooks"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

echo "📦 Installing security hooks..."

# 复制 pre-commit hook
cp "$SCRIPT_DIR/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Hooks installed successfully!"
echo "🔒 Your commits will now be checked for private keys"
```

#### 1.4 使用方法

在其他项目中：

```bash
# 方法 1: 作为 git submodule
git submodule add https://github.com/yourusername/git-hooks-security .githooks
.githooks/install.sh

# 方法 2: 直接下载
curl -o install-hooks.sh https://raw.githubusercontent.com/yourusername/git-hooks-security/main/install.sh
chmod +x install-hooks.sh
./install-hooks.sh
```

---

### 方案 2: GitHub Actions（云端强制执行）

创建 GitHub Action 来在 CI/CD 中检查私钥。

#### 2.1 创建 Action 文件

在你的 hooks repository 中创建：`.github/workflows/check-secrets.yml`

```yaml
name: Security - Check for Private Keys

on:
  pull_request:
    branches: [ main, master, develop ]
  push:
    branches: [ main, master, develop ]

jobs:
  check-secrets:
    runs-on: ubuntu-latest
    name: Scan for Private Keys
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Check for private keys
        run: |
          #!/bin/bash
          set -e
          
          RED='\033[0;31m'
          GREEN='\033[0;32m'
          YELLOW='\033[1;33m'
          BLUE='\033[0;34m'
          NC='\033[0m'
          
          EXCLUDED_DIRS="node_modules|\.git|\.netlify|\.svelte-kit|build|dist|\.next|contracts/broadcast|contracts/cache|contracts/lib|test-results|playwright-report|\.auth"
          SCAN_EXTENSIONS="\.(ts|tsx|js|jsx|svelte|sol|md|json|env|example)$"
          
          echo -e "${BLUE}🔒 Scanning repository for private keys...${NC}\n"
          
          # 获取所有文件（排除特定目录）
          FILES_TO_SCAN=$(find . -type f | grep -E "$SCAN_EXTENSIONS" | grep -v -E "$EXCLUDED_DIRS" || true)
          
          if [ -z "$FILES_TO_SCAN" ]; then
            echo -e "${GREEN}✅ No files to scan${NC}"
            exit 0
          fi
          
          # 检测模式
          ETHEREUM_KEY_PATTERN='0x[a-fA-F0-9]{64}'
          PEM_PATTERN='BEGIN.*PRIVATE KEY'
          AWS_ACCESS_PATTERN='AKIA[0-9A-Z]{16}'
          PRIVATE_KEY_WITH_VALUE_PATTERN='private[_-]key[[:space:]]*[:=][[:space:]]*0x[a-fA-F0-9]{32,}'
          
          FOUND_SECRETS=0
          
          for FILE in $FILES_TO_SCAN; do
            if [ ! -f "$FILE" ]; then
              continue
            fi
            
            FINDINGS=""
            
            if grep -nE "$ETHEREUM_KEY_PATTERN" "$FILE" > /dev/null 2>&1; then
              FINDINGS="${FINDINGS}   [CRITICAL] Ethereum Private Key\n"
              FINDINGS="${FINDINGS}$(grep -nE "$ETHEREUM_KEY_PATTERN" "$FILE" | sed 's/^/     /')\n"
              FOUND_SECRETS=1
            fi
            
            if grep -nE "$PEM_PATTERN" "$FILE" > /dev/null 2>&1; then
              FINDINGS="${FINDINGS}   [CRITICAL] PEM Private Key\n"
              FINDINGS="${FINDINGS}$(grep -nE "$PEM_PATTERN" "$FILE" | sed 's/^/     /')\n"
              FOUND_SECRETS=1
            fi
            
            if grep -nE "$AWS_ACCESS_PATTERN" "$FILE" > /dev/null 2>&1; then
              FINDINGS="${FINDINGS}   [CRITICAL] AWS Access Key\n"
              FINDINGS="${FINDINGS}$(grep -nE "$AWS_ACCESS_PATTERN" "$FILE" | sed 's/^/     /')\n"
              FOUND_SECRETS=1
            fi
            
            if grep -nEi "$PRIVATE_KEY_WITH_VALUE_PATTERN" "$FILE" > /dev/null 2>&1; then
              PRIVATE_KEY_LINES=$(grep -nEi "$PRIVATE_KEY_WITH_VALUE_PATTERN" "$FILE" | grep -v "^[[:space:]]*#" | grep -v "^[[:space:]]*//")
              if [ -n "$PRIVATE_KEY_LINES" ]; then
                FINDINGS="${FINDINGS}   [CRITICAL] Private Key with Value\n"
                FINDINGS="${FINDINGS}$(echo "$PRIVATE_KEY_LINES" | sed 's/^/     /')\n"
                FOUND_SECRETS=1
              fi
            fi
            
            if [ -n "$FINDINGS" ]; then
              echo -e "${RED}❌ ${FILE}:${NC}"
              echo -e "$FINDINGS"
            fi
          done
          
          if [ $FOUND_SECRETS -eq 1 ]; then
            echo -e "${RED}========================================${NC}"
            echo -e "${RED}🚨 PRIVATE KEYS DETECTED!${NC}\n"
            echo -e "${YELLOW}Please remove private keys before merging${NC}\n"
            exit 1
          fi
          
          echo -e "${GREEN}✅ No private keys detected${NC}"
          exit 0
```

#### 2.2 在其他项目中使用

只需将上述 workflow 文件复制到目标项目的 `.github/workflows/` 目录即可。

或者创建一个可复用的 Action：

```yaml
# 在其他项目中使用
name: Security Check

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: yourusername/git-hooks-security/.github/actions/check-secrets@main
```

---

### 方案 3: Husky + 自定义脚本（现代化）

使用 Husky 来管理 git hooks，适合 Node.js 项目。

#### 3.1 安装 Husky

```bash
pnpm add -D husky
pnpm exec husky init
```

#### 3.2 创建检查脚本

创建 `scripts/check-secrets.sh`（从你的 pre-commit 提取核心逻辑）：

```bash
#!/bin/bash
# 将你的 pre-commit 脚本内容放在这里
# 或者从独立 repository 下载
```

#### 3.3 配置 Husky

```bash
# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

./scripts/check-secrets.sh
```

#### 3.4 分享到其他项目

将 `scripts/check-secrets.sh` 和 Husky 配置添加到 `package.json`:

```json
{
  "scripts": {
    "prepare": "husky install"
  },
  "devDependencies": {
    "husky": "^8.0.0"
  }
}
```

团队成员运行 `pnpm install` 后会自动安装 hooks。

---

## 🎖️ 推荐方案组合

**最佳实践：方案 1 + 方案 2**

1. **本地开发**：使用方案 1 的独立 hooks repository
   - 快速反馈
   - 开发者友好
   - 可以被绕过（`git commit --no-verify`）

2. **CI/CD**：使用方案 2 的 GitHub Actions
   - 强制执行，无法绕过
   - 保护主分支
   - 团队协作必备

## 📦 实施步骤

### Step 1: 创建 Hooks Repository

```bash
# 创建新 repo
mkdir git-hooks-security
cd git-hooks-security
git init

# 复制当前的 pre-commit
cp /path/to/current/project/.git/hooks/pre-commit hooks/pre-commit

# 创建安装脚本（见上文）
# 创建 GitHub Action（见上文）

# 提交并推送
git add .
git commit -m "feat: add security hooks for private key detection"
git remote add origin https://github.com/yourusername/git-hooks-security.git
git push -u origin main
```

### Step 2: 在其他项目中使用

```bash
# 进入目标项目
cd /path/to/other/project

# 安装 hooks
curl -sSL https://raw.githubusercontent.com/yourusername/git-hooks-security/main/install.sh | bash

# 或者作为 submodule
git submodule add https://github.com/yourusername/git-hooks-security .githooks
.githooks/install.sh

# 添加 GitHub Action
mkdir -p .github/workflows
curl -o .github/workflows/check-secrets.yml \
  https://raw.githubusercontent.com/yourusername/git-hooks-security/main/.github/workflows/check-secrets.yml
```

### Step 3: 团队使用

在项目的 `README.md` 中添加：

```markdown
## 🔒 Security Setup

This project uses automated security checks to prevent committing private keys.

### First-time setup:

\`\`\`bash
# Install git hooks
.githooks/install.sh
\`\`\`

The hooks will automatically check for:
- Ethereum private keys
- PEM format keys
- AWS credentials
- Other sensitive data

### CI/CD

GitHub Actions will also scan all PRs and commits to the main branch.
```

---

## 🔧 高级配置

### 自定义检测规则

在 hooks repository 中创建配置文件 `config.json`:

```json
{
  "patterns": {
    "ethereum_key": "0x[a-fA-F0-9]{64}",
    "pem_key": "BEGIN.*PRIVATE KEY",
    "aws_access": "AKIA[0-9A-Z]{16}",
    "custom_api_key": "sk-[a-zA-Z0-9]{48}"
  },
  "excluded_dirs": [
    "node_modules",
    ".git",
    "dist",
    "build"
  ],
  "scan_extensions": [
    ".ts",
    ".js",
    ".sol",
    ".env"
  ]
}
```

### 更新所有项目的 Hooks

创建 `update-all.sh`:

```bash
#!/bin/bash
# 批量更新多个项目的 hooks

PROJECTS=(
  "/path/to/project1"
  "/path/to/project2"
  "/path/to/project3"
)

for PROJECT in "${PROJECTS[@]}"; do
  echo "Updating hooks in $PROJECT"
  cd "$PROJECT"
  .githooks/install.sh
done
```

---

## 📊 对比总结

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **独立 Hooks 包** | 灵活、易维护、跨项目 | 可被绕过 | 个人项目、多项目管理 |
| **GitHub Actions** | 强制执行、云端 | 需要 GitHub、延迟反馈 | 团队协作、开源项目 |
| **Husky** | 现代化、自动化 | 仅限 Node.js 项目 | 前端/全栈项目 |

## 🎯 我的建议

基于你的需求（多个 repository 复用），我建议：

1. ✅ **创建独立的 `git-hooks-security` repository**
2. ✅ **提供 GitHub Action 版本**
3. ✅ **在每个项目的 README 中说明安装方法**
4. ✅ **定期更新和维护 hooks repository**

这样你可以：
- 🔄 集中管理所有安全检查规则
- 📦 一键安装到任何项目
- ☁️ CI/CD 强制执行
- 🚀 持续改进和更新

---

## 📝 下一步

你想让我帮你：
1. 创建独立的 hooks repository 结构？
2. 生成完整的安装脚本？
3. 创建 GitHub Action workflow？
4. 还是三个都做？
