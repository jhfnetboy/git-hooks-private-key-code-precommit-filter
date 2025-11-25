# 🛡️ Git Hooks - Private Key & API Key Filter

<div align="center">

<!-- Placeholder for Logo -->
<!-- <img src="docs/images/logo.png" alt="Git Hooks Security Logo" width="200"/> -->

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Security](https://img.shields.io/badge/Security-Hardened-success?style=for-the-badge&logo=security&logoColor=white)](https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)

[English](#english) | [中文](#chinese)

</div>

---

<a name="english"></a>
## 🇬🇧 English

A powerful Git pre-commit hook and GitHub Actions workflow designed to automatically detect and prevent the commit of private keys, API keys, and other sensitive information.

### 🎯 Features

#### ✅ Supported Key Types

- **Blockchain Private Keys**
  - ✅ Ethereum Private Keys (0x + 64 hex characters)
  - ✅ PEM Format Private Keys (BEGIN PRIVATE KEY)

- **Cloud Service Keys**
  - ✅ AWS Access Keys (AKIA...)
  - ✅ AWS Secret Keys

- **AI Service API Keys**
  - ✅ OpenAI API Keys (sk-..., sk-proj-...)
  - ✅ Google AI (Gemini) API Keys (AIza...)
  - ✅ Anthropic (Claude) API Keys (sk-ant-...)

- **Developer Tool Keys**
  - ✅ GitHub Personal Access Tokens (ghp_..., gho_..., ghs_...)
  - ✅ Stripe API Keys (sk_live_..., sk_test_...)

- **Generic Patterns**
  - ✅ Private keys with actual values (private_key=0x...)
  - ✅ Generic API key patterns (api_key="...")

#### 🛡️ Dual Protection

1.  **Local Git Hook** - Instant feedback, detects issues before commit.
2.  **GitHub Actions** - Cloud-based enforcement, protects the main branch.

#### 🎨 Smart Filtering

- ✅ Detects only actual key values.
- ✅ Allows placeholders and empty values.
- ✅ Allows keywords in documentation.
- ✅ Automatically excludes `node_modules`, `dist`, etc.
- ✅ Filters out comment lines.

### 🚀 Quick Start

#### Method 1: One-Click Deployment (Recommended)

```bash
# Clone this repository
git clone https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git

# Go to your project directory
cd /path/to/your/project

# Run the deployment script
/path/to/git-hooks-private-key-code-precommit-filter/scripts/deploy-to-project.sh .
```

#### Method 2: As Git Submodule

```bash
# Add as a submodule to your project
git submodule add https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git .githooks

# Run the install script
.githooks/scripts/install-hooks.sh
```

#### Method 3: Manual Installation

```bash
# 1. Copy pre-commit hook
curl -o .git/hooks/pre-commit https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 2. Copy GitHub Actions workflow
mkdir -p .github/workflows
curl -o .github/workflows/check-secrets.yml https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/.github/workflows/check-secrets.yml
```

---

<a name="chinese"></a>
## 🇨🇳 中文

一个强大的 Git pre-commit hook 和 GitHub Actions，用于自动检测和防止提交私钥、API keys 和其他敏感信息。

### 🎯 功能特性

#### ✅ 支持检测的密钥类型

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

#### 🛡️ 双重保护

1.  **本地 Git Hook** - 快速反馈，在提交前立即检测
2.  **GitHub Actions** - 云端强制执行，保护主分支

#### 🎨 智能过滤

- ✅ 只检测实际的密钥值
- ✅ 允许占位符和空值
- ✅ 允许文档中的关键词
- ✅ 自动排除 `node_modules`、`dist` 等目录
- ✅ 过滤注释行

### 🚀 快速开始

#### 方法 1: 一键部署（推荐）

```bash
# Clone 这个 repository
git clone https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git

# 进入你的项目目录
cd /path/to/your/project

# 运行部署脚本
/path/to/git-hooks-private-key-code-precommit-filter/scripts/deploy-to-project.sh .
```

#### 方法 2: 作为 Git Submodule

```bash
# 在你的项目中添加为 submodule
git submodule add https://github.com/jhfnetboy/git-hooks-private-key-code-precommit-filter.git .githooks

# 运行安装脚本
.githooks/scripts/install-hooks.sh
```

#### 方法 3: 手动安装

```bash
# 1. 复制 pre-commit hook
curl -o .git/hooks/pre-commit https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 2. 复制 GitHub Actions workflow
mkdir -p .github/workflows
curl -o .github/workflows/check-secrets.yml https://raw.githubusercontent.com/jhfnetboy/git-hooks-private-key-code-precommit-filter/main/.github/workflows/check-secrets.yml
```

---

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Made with ❤️ for secure coding</sub>
</div>
