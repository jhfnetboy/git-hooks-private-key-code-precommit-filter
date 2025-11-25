# 🔒 Git Hooks - Private Key & API Key Filter

一个强大的 Git pre-commit hook 和 GitHub Actions，用于自动检测和防止提交私钥、API keys 和其他敏感信息。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue)](https://github.com/features/actions)

## 🎯 功能特性

### ✅ 支持检测的密钥类型

- **区块链私钥**
  - ✅ Ethereum 私钥 (0x + 64位十六进制)
  - ✅ PEM 格式私钥 (BEGIN PRIVATE KEY)

- **云服务密钥**
  - ✅ AWS Access Keys (AKIA...)
  - ✅ AWS Secret Keys

- **AI 服务 API Keys**
  - ✅ OpenAI API Keys (sk-..., sk-proj-...)
  - ✅ Google AI (Gemini) API Keys (AIza...)
  - ✅ Anthropic (Claude) API Keys (sk-ant-...)

- **开发工具密钥**
  - ✅ GitHub Personal Access Tokens (ghp_..., gho_..., ghs_...)
  - ✅ Stripe API Keys (sk_live_..., sk_test_...)

- **通用模式**
  - ✅ 带有实际值的私钥 (private_key=0x...)
  - ✅ 通用 API key 模式 (api_key="...")

### 🛡️ 双重保护

1. **本地 Git Hook** - 快速反馈，在提交前立即检测
2. **GitHub Actions** - 云端强制执行，保护主分支

### 🎨 智能过滤

- ✅ 只检测实际的密钥值
- ✅ 允许占位符和空值
- ✅ 允许文档中的关键词
- ✅ 自动排除 node_modules、dist 等目录
- ✅ 过滤注释行

---

## 🚀 快速开始

### 方法 1: 一键部署（推荐）

```bash
# Clone 这个 repository
git clone https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git

# 进入你的项目目录
cd /path/to/your/project

# 运行部署脚本
/path/to/git-hooks-private-key-code-precommit-filter/scripts/deploy-to-project.sh .
```

### 方法 2: 作为 Git Submodule

```bash
# 在你的项目中添加为 submodule
git submodule add https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git .githooks

# 运行安装脚本
.githooks/scripts/install-hooks.sh
```

### 方法 3: 手动安装

```bash
# 1. 复制 pre-commit hook
curl -o .git/hooks/pre-commit https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 2. 复制 GitHub Actions workflow
mkdir -p .github/workflows
curl -o .github/workflows/check-secrets.yml https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/.github/workflows/check-secrets.yml
```

---

## 📖 使用说明

### 本地 Git Hook

安装后，每次 `git commit` 时会自动检查：

```bash
# 正常提交
git add .
git commit -m "feat: add new feature"

# 如果检测到私钥，会阻止提交并显示详细信息
# 🚨 COMMIT BLOCKED: Private keys detected!
```

**输出示例：**

```
🔒 Pre-commit hook: Checking for private keys...

📋 Scanning 15 file(s) for private keys...

❌ src/config.ts:
   [CRITICAL] OpenAI API Key
     12: const OPENAI_KEY = "sk-1234567890abcdef..."

❌ .env:
   [CRITICAL] Ethereum Private Key (256-bit hex)
     3: PRIVATE_KEY=0x1234567890abcdef...

=================================================================================
🚨 COMMIT BLOCKED: Private keys detected!

⚠️  Do NOT commit files containing private keys!

Actions to take:
  1. Remove the private key(s) from the file(s)
  2. Ensure sensitive data is NOT in version control
  3. Use .env files for secrets (and add to .gitignore)
  4. Stage the corrected files again
  5. Try committing again

=================================================================================
```

### GitHub Actions

当你推送代码或创建 PR 时，GitHub Actions 会自动运行检查：

- ✅ **通过**：显示绿色勾
- ❌ **失败**：显示红色叉，并在 PR 中自动评论

---

## 🔍 检测示例

### ❌ 会被阻止的内容

```javascript
// ❌ Ethereum 私钥
const PRIVATE_KEY = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";

// ❌ OpenAI API Key
const OPENAI_API_KEY = "sk-proj-1234567890abcdefghijklmnopqrstuvwxyz";

// ❌ Google AI (Gemini) API Key
const GEMINI_KEY = "AIzaSyC1234567890abcdefghijklmnopqrstuvwxyz";

// ❌ Anthropic (Claude) API Key
const CLAUDE_KEY = "sk-ant-api03-1234567890abcdefghijklmnopqrstuvwxyz...";

// ❌ GitHub Token
const GITHUB_TOKEN = "ghp_1234567890abcdefghijklmnopqrstuvwxyz";

// ❌ AWS 密钥
const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
const AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";

// ❌ PEM 私钥
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASC...
-----END PRIVATE KEY-----
```

### ✅ 允许的内容

```javascript
// ✅ 空值
const PRIVATE_KEY = "";
const API_KEY = "";

// ✅ 占位符
const PRIVATE_KEY = "your_private_key_here";
const API_KEY = "paste_your_api_key_here";

// ✅ 环境变量引用
const privateKey = process.env.PRIVATE_KEY;
const apiKey = process.env.OPENAI_API_KEY;

// ✅ 注释和文档
// Please set your PRIVATE_KEY in .env file
// Get your API key from https://platform.openai.com/api-keys

// ✅ .env.example 文件
PRIVATE_KEY=
OPENAI_API_KEY=
GOOGLE_AI_KEY=
```

---

## 📁 项目结构

```
git-hooks-private-key-code-precommit-filter/
├── README.md                       # 本文件
├── LICENSE                         # MIT 许可证
├── hooks/
│   └── pre-commit                  # Git pre-commit hook 脚本
├── scripts/
│   ├── install-hooks.sh            # 安装脚本
│   └── deploy-to-project.sh        # 一键部署脚本
├── .github/workflows/
│   └── check-secrets.yml           # GitHub Actions workflow
└── docs/
    ├── GIT_HOOKS_SECURITY_README.md        # 详细使用文档
    ├── pre-commit-hook-reuse-guide.md      # 复用指南
    └── QUICK_REFERENCE.md                  # 快速参考
```

---

## 🛠️ 高级配置

### 自定义扫描的文件类型

编辑 `hooks/pre-commit` 中的 `SCAN_EXTENSIONS`：

```bash
SCAN_EXTENSIONS="\.(ts|tsx|js|jsx|svelte|sol|md|json|env|example)$"
```

### 添加排除目录

编辑 `EXCLUDED_DIRS`：

```bash
EXCLUDED_DIRS="node_modules|\.git|build|dist|your_custom_dir"
```

### 添加自定义检测模式

在 `hooks/pre-commit` 中添加新的正则表达式：

```bash
# 例如：检测 Hugging Face tokens
HUGGINGFACE_TOKEN_PATTERN='hf_[a-zA-Z0-9]{32,}'

if grep -nE "$HUGGINGFACE_TOKEN_PATTERN" "$FILE" > /dev/null 2>&1; then
  FINDINGS="${FINDINGS}   [CRITICAL] Hugging Face Token\n"
  FOUND_SECRETS=1
fi
```

---

## 🎯 最佳实践

### 1. 使用 .env 文件管理敏感信息

```bash
# .env (添加到 .gitignore)
PRIVATE_KEY=0x1234...
OPENAI_API_KEY=sk-1234...
GOOGLE_AI_KEY=AIza1234...
```

### 2. 提供 .env.example 模板

```bash
# .env.example (可以提交到 git)
PRIVATE_KEY=
OPENAI_API_KEY=
GOOGLE_AI_KEY=
```

### 3. 在 README 中说明设置步骤

```markdown
## Setup

1. Copy `.env.example` to `.env`:
   \`\`\`bash
   cp .env.example .env
   \`\`\`

2. Fill in your credentials in `.env`

3. **NEVER commit the `.env` file!**
```

### 4. 确保 .gitignore 包含敏感文件

```gitignore
# Environment variables
.env
.env.local

# Private keys
*.pem
*.key
```

---

## 🔧 故障排除

### Hook 没有运行？

```bash
# 检查 hook 是否存在
ls -la .git/hooks/pre-commit

# 确保可执行
chmod +x .git/hooks/pre-commit

# 手动测试
.git/hooks/pre-commit
```

### GitHub Actions 没有运行？

1. 检查 workflow 文件路径：`.github/workflows/check-secrets.yml`
2. 查看 Actions 日志获取详细错误信息
3. 确保 repository 启用了 GitHub Actions

### 误报问题？

如果某些内容被错误标记：

1. 确认不是真实的密钥值
2. 使用注释说明：`// Example key (not real)`
3. 将文件添加到排除列表

---

## 📊 支持的密钥格式

| 类型 | 模式 | 示例 |
|------|------|------|
| Ethereum Private Key | `0x[a-fA-F0-9]{64}` | `0x1234...` |
| OpenAI API Key | `sk-[a-zA-Z0-9]{48,}` | `sk-1234...` |
| OpenAI Project Key | `sk-proj-[a-zA-Z0-9_-]{48,}` | `sk-proj-1234...` |
| Google AI (Gemini) | `AIza[a-zA-Z0-9_-]{35,}` | `AIzaSyC1234...` |
| Anthropic (Claude) | `sk-ant-[a-zA-Z0-9_-]{95,}` | `sk-ant-api03-...` |
| GitHub PAT | `gh[pousr]_[a-zA-Z0-9]{36,}` | `ghp_1234...` |
| AWS Access Key | `AKIA[0-9A-Z]{16}` | `AKIAIOSFODNN7...` |
| Stripe API Key | `sk_(live\|test)_[a-zA-Z0-9]{24,}` | `sk_live_1234...` |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 如何贡献

1. Fork 这个 repository
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

### 添加新的密钥检测模式

如果你想添加对新类型密钥的检测，请：

1. 在 `hooks/pre-commit` 中添加检测模式
2. 在 `.github/workflows/check-secrets.yml` 中添加相同的模式
3. 更新 README.md 中的支持列表
4. 提供测试示例

---

## 📚 相关资源

- [Git Hooks 官方文档](https://git-scm.com/docs/githooks)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [git-secrets](https://github.com/awslabs/git-secrets) - AWS Labs 的密钥检测工具
- [truffleHog](https://github.com/trufflesecurity/trufflehog) - 扫描 git 历史中的密钥
- [gitleaks](https://github.com/gitleaks/gitleaks) - 另一个流行的密钥扫描工具

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## ⚠️ 重要提醒

**永远不要提交真实的私钥和敏感信息！** 🔐

即使有这些工具的保护，你仍然应该：

1. ✅ 使用 `.env` 文件存储敏感信息
2. ✅ 将 `.env` 添加到 `.gitignore`
3. ✅ 定期轮换密钥和 tokens
4. ✅ 使用密钥管理服务（如 AWS Secrets Manager、HashiCorp Vault）
5. ✅ 定期审计代码库中的敏感信息

---

## 🌟 Star History

如果这个项目对你有帮助，请给个 ⭐️！

---

**Made with ❤️ for secure coding**
