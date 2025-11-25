# 🎯 Pre-commit Hook 复用方案 - 快速参考

## 📌 问题
如何将当前项目的 pre-commit hook（私钥检测）复用到其他 repository？

## ✅ 解决方案

我为你创建了 **三种方案**，推荐使用 **方案 1 + 方案 2 组合**。

---

## 🚀 方案对比

| 方案 | 类型 | 优点 | 缺点 | 推荐度 |
|------|------|------|------|--------|
| **方案 1** | 独立脚本 | 快速、灵活、跨项目 | 可被 --no-verify 绕过 | ⭐⭐⭐⭐⭐ |
| **方案 2** | GitHub Actions | 云端强制、无法绕过 | 需要 GitHub、延迟反馈 | ⭐⭐⭐⭐⭐ |
| **方案 3** | Husky | 现代化、自动化 | 仅限 Node.js 项目 | ⭐⭐⭐ |

---

## 🎯 推荐方案：方案 1 + 方案 2

### 为什么？
- ✅ **本地快速反馈**：开发时立即发现问题
- ✅ **云端强制执行**：防止绕过，保护主分支
- ✅ **双重保险**：本地 + CI/CD 两层防护

---

## 📦 已创建的文件

我已经为你创建了以下文件：

```
LeakShield/
├── .github/workflows/
│   └── check-secrets.yml           # GitHub Actions workflow
├── scripts/
│   ├── install-hooks.sh            # 安装脚本
│   └── deploy-to-project.sh        # 一键部署脚本 ⭐
└── docs/
    ├── pre-commit-hook-reuse-guide.md      # 详细指南
    ├── GIT_HOOKS_SECURITY_README.md        # 使用文档
    └── QUICK_REFERENCE.md                  # 本文件
```

---

## 🔥 快速使用（三种方法）

### 方法 1: 一键部署（最简单）⭐

```bash
# 在当前项目中运行
./scripts/deploy-to-project.sh /path/to/target/project

# 示例
./scripts/deploy-to-project.sh ~/projects/my-other-repo
```

**这会自动：**
- ✅ 复制 pre-commit hook
- ✅ 复制 GitHub Actions
- ✅ 复制文档
- ✅ 更新 .gitignore
- ✅ 创建 .env.example

---

### 方法 2: 手动复制

```bash
# 1. 复制 pre-commit hook
cp .git/hooks/pre-commit /path/to/target/.git/hooks/pre-commit
chmod +x /path/to/target/.git/hooks/pre-commit

# 2. 复制 GitHub Actions
mkdir -p /path/to/target/.github/workflows
cp .github/workflows/check-secrets.yml /path/to/target/.github/workflows/

# 3. 复制文档（可选）
cp docs/GIT_HOOKS_SECURITY_README.md /path/to/target/docs/
```

---

### 方法 3: 创建独立的 Hooks Repository

如果你有很多项目需要使用，建议创建一个独立的 repository：

```bash
# 1. 创建新 repo
mkdir git-hooks-security
cd git-hooks-security

# 2. 复制文件
cp -r /path/to/LeakShield/.git/hooks/pre-commit hooks/
cp -r /path/to/LeakShield/.github/workflows/check-secrets.yml .github/workflows/
cp /path/to/LeakShield/scripts/install-hooks.sh .
cp /path/to/LeakShield/docs/GIT_HOOKS_SECURITY_README.md README.md

# 3. 推送到 GitHub
git init
git add .
git commit -m "feat: initial commit"
git remote add origin https://github.com/yourusername/git-hooks-security.git
git push -u origin main
```

然后在其他项目中：

```bash
# 作为 submodule
git submodule add https://github.com/yourusername/git-hooks-security .githooks
.githooks/install.sh

# 或直接下载
curl -sSL https://raw.githubusercontent.com/yourusername/git-hooks-security/main/install.sh | bash
```

---

## 🎬 使用示例

### 场景 1: 部署到单个项目

```bash
# 在 LeakShield 项目中
cd /Users/jason/Dev/mycelium/my-exploration/projects/LeakShield

# 部署到另一个项目
./scripts/deploy-to-project.sh ~/projects/another-web3-project

# 输出：
# 🚀 Deploying Security Hooks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ✅ Git hook installed
# ✅ GitHub Actions workflow installed
# ✅ Documentation copied
# ✅ Deployment Complete!
```

### 场景 2: 批量部署到多个项目

创建一个批量脚本：

```bash
#!/bin/bash
# batch-deploy.sh

PROJECTS=(
  "$HOME/projects/project1"
  "$HOME/projects/project2"
  "$HOME/projects/project3"
)

for PROJECT in "${PROJECTS[@]}"; do
  echo "Deploying to $PROJECT"
  ./scripts/deploy-to-project.sh "$PROJECT"
  echo ""
done
```

### 场景 3: 在新项目中使用

```bash
# 1. 创建新项目
mkdir my-new-project
cd my-new-project
git init

# 2. 部署安全检查
/path/to/LeakShield/scripts/deploy-to-project.sh .

# 3. 开始开发
# 现在所有 commits 都会被检查！
```

---

## 🔍 检测能力

### ✅ 会检测的内容

```javascript
// ❌ Ethereum 私钥
PRIVATE_KEY=0x...

// ❌ PEM 私钥
-----BEGIN PRIVATE KEY (EXAMPLE)-----
...
-----END PRIVATE KEY (EXAMPLE)-----

// ❌ AWS 密钥
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=wJalr...

// ❌ API Keys
API_KEY="sk-..."
```

### ✅ 不会误报的内容

```javascript
// ✅ 空值
PRIVATE_KEY=

// ✅ 占位符
PRIVATE_KEY=your_private_key_here

// ✅ 环境变量
const key = process.env.PRIVATE_KEY;

// ✅ 注释
// Set your PRIVATE_KEY in .env file
```

---

## 📊 工作流程

### 本地开发流程

```
开发者写代码
    ↓
git add .
    ↓
git commit -m "message"
    ↓
pre-commit hook 自动运行
    ↓
┌─────────────────┐
│ 检测到私钥？    │
└─────────────────┘
    ↓           ↓
   是          否
    ↓           ↓
❌ 阻止提交    ✅ 允许提交
显示详细信息
```

### CI/CD 流程

```
开发者 push 代码
    ↓
GitHub Actions 触发
    ↓
扫描所有文件
    ↓
┌─────────────────┐
│ 发现私钥？      │
└─────────────────┘
    ↓           ↓
   是          否
    ↓           ↓
❌ PR 失败      ✅ PR 通过
在 PR 中评论    显示绿色勾
```

---

## 🛠️ 故障排除

### 问题 1: Hook 没有运行

```bash
# 检查 hook 文件
ls -la .git/hooks/pre-commit

# 确保可执行
chmod +x .git/hooks/pre-commit

# 手动测试
.git/hooks/pre-commit
```

### 问题 2: GitHub Actions 没有运行

```bash
# 检查 workflow 文件
cat .github/workflows/check-secrets.yml

# 确保在正确的分支
git branch

# 查看 Actions 页面
# https://github.com/username/repo/actions
```

### 问题 3: 误报

如果某些内容被错误标记：

1. 确认不是真实的密钥
2. 添加注释说明：`// Example only, not a real key`
3. 将文件添加到排除列表

---

## 📚 详细文档

- **完整指南**: `docs/pre-commit-hook-reuse-guide.md`
- **使用文档**: `docs/GIT_HOOKS_SECURITY_README.md`
- **本文件**: `docs/QUICK_REFERENCE.md`

---

## 🎯 最佳实践

### 1. 使用 .env 文件

```bash
# .env (添加到 .gitignore)
PRIVATE_KEY=0x1234...
API_KEY=sk-1234...

# .env.example (可以提交)
PRIVATE_KEY=
API_KEY=
```

### 2. 在 README 中说明

```markdown
## Setup

1. Copy `.env.example` to `.env`:
   \`\`\`bash
   cp .env.example .env
   \`\`\`

2. Fill in your credentials in `.env`

3. **NEVER commit the `.env` file!**
```

### 3. 团队协作

```bash
# 在项目 README 中添加
## Security Setup

This project uses automated security checks.

### First-time setup:
\`\`\`bash
# Hooks are automatically installed
# Or manually run:
.githooks/install.sh
\`\`\`
```

---

## 🚀 下一步

### 立即行动

1. **测试一键部署**
   ```bash
   ./scripts/deploy-to-project.sh /path/to/test/project
   ```

2. **创建独立 repository**（如果有多个项目）
   ```bash
   # 按照"方法 3"创建 git-hooks-security repo
   ```

3. **更新团队文档**
   - 在 README 中说明安全检查
   - 分享给团队成员

### 进阶优化

1. **添加更多检测规则**
   - OpenAI API keys
   - Database passwords
   - JWT secrets

2. **集成其他工具**
   - git-secrets
   - truffleHog
   - gitleaks

3. **自动化更新**
   - 使用 git submodule
   - 定期同步最新版本

---

## 💡 总结

### 你现在拥有：

✅ **三种复用方案**
- 独立脚本（灵活）
- GitHub Actions（强制）
- Husky（现代化）

✅ **完整的工具集**
- 一键部署脚本
- 安装脚本
- GitHub Actions workflow
- 详细文档

✅ **最佳实践**
- 本地 + 云端双重保护
- 智能检测，避免误报
- 易于维护和更新

### 推荐做法：

🎯 **现在就试试一键部署！**

```bash
./scripts/deploy-to-project.sh /path/to/your/other/project
```

---

**记住：安全第一，永远不要提交真实的私钥！** 🔐
