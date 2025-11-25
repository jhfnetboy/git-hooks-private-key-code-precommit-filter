# 🔒 LeakShield - 私钥检测工具

这是一个用于检测和防止提交私钥、API keys 和其他敏感信息的工具集。

## 📋 功能特性

✅ **自动检测多种敏感信息：**
- Ethereum 私钥 (0x + 64位十六进制)
- PEM 格式私钥 (BEGIN ... PRIVATE KEY)
- AWS Access Keys (AKIA...)
- AWS Secret Keys
- 其他带有实际值的私钥
- API Keys

✅ **双重保护：**
- 本地 Git Hook（快速反馈）
- GitHub Actions（云端强制执行）

✅ **智能过滤：**
- 只检测实际的密钥值
- 允许占位符和文档中的关键词
- 自动排除 node_modules、dist 等目录

## 🚀 快速开始

### 方法 1: 在当前项目使用

如果你已经在这个项目中，hooks 已经配置好了！

### 方法 2: 复制到其他项目

#### 选项 A: 使用安装脚本

```bash
# 1. 进入目标项目
cd /path/to/your/project

# 2. 复制安装脚本
curl -O https://raw.githubusercontent.com/yourusername/yourrepo/main/scripts/install-hooks.sh

# 3. 复制 pre-commit hook
mkdir -p .githooks
curl -o .githooks/pre-commit https://raw.githubusercontent.com/yourusername/yourrepo/main/.git/hooks/pre-commit

# 4. 运行安装
chmod +x install-hooks.sh
./install-hooks.sh
```

#### 选项 B: 手动安装

```bash
# 1. 复制 pre-commit 文件
cp /path/to/this/project/.git/hooks/pre-commit /path/to/target/project/.git/hooks/pre-commit

# 2. 确保可执行
chmod +x /path/to/target/project/.git/hooks/pre-commit
```

#### 选项 C: 添加 GitHub Actions

```bash
# 复制 workflow 文件到目标项目
mkdir -p .github/workflows
cp .github/workflows/check-secrets.yml /path/to/target/project/.github/workflows/
```

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

**绕过检查（不推荐）：**
```bash
git commit --no-verify -m "message"
```

### GitHub Actions

当你推送代码或创建 PR 时，GitHub Actions 会自动运行检查：

- ✅ 通过：显示绿色勾
- ❌ 失败：显示红色叉，并在 PR 中评论

## 🔍 检测示例

### ❌ 会被阻止的内容：

```javascript
// ❌ 实际的 Ethereum 私钥
const PRIVATE_KEY = "0x..."; // YOUR_PRIVATE_KEY

// ❌ PEM 格式私钥
-----BEGIN PRIVATE KEY (EXAMPLE)-----
...
-----END PRIVATE KEY (EXAMPLE)-----

// ❌ AWS 密钥
const AWS_ACCESS_KEY = "AKIA...";
const AWS_SECRET_KEY = "wJalr...";
```

### ✅ 允许的内容：

```javascript
// ✅ 空值
const PRIVATE_KEY = "";

// ✅ 占位符
const PRIVATE_KEY_PLACEHOLDER = "paste_your_key_here";

// ✅ 环境变量引用
const privateKey = process.env.PRIVATE_KEY;

// ✅ 文档说明
// Please set your private key in .env file

// ✅ .env.example 文件
PRIVATE_KEY=
API_KEY=your_api_key_here
```

## 📁 项目结构

```
.
├── .git/hooks/
│   └── pre-commit              # 本地 Git Hook
├── .github/workflows/
│   └── check-secrets.yml       # GitHub Actions workflow
├── scripts/
│   └── install-hooks.sh        # 安装脚本
└── docs/
    └── pre-commit-hook-reuse-guide.md  # 详细指南
```

## 🛠️ 自定义配置

### 修改扫描的文件类型

编辑 `.git/hooks/pre-commit` 中的 `SCAN_EXTENSIONS`：

```bash
SCAN_EXTENSIONS="\.(ts|tsx|js|jsx|svelte|sol|md|json|env|example)$"
```

### 添加排除目录

编辑 `EXCLUDED_DIRS`：

```bash
EXCLUDED_DIRS="node_modules|\.git|build|dist|your_custom_dir"
```

### 添加自定义检测模式

在 pre-commit 脚本中添加新的正则表达式：

```bash
# 例如：检测 OpenAI API keys
OPENAI_KEY_PATTERN='sk-[a-zA-Z0-9]{48}'

if grep -nE "$OPENAI_KEY_PATTERN" "$FILE" > /dev/null 2>&1; then
  FINDINGS="${FINDINGS}   [CRITICAL] OpenAI API Key\n"
  FOUND_SECRETS=1
fi
```

## 🔄 更新 Hooks

当 hook 脚本更新后，在其他项目中重新运行安装脚本：

```bash
./install-hooks.sh
```

或者使用 git submodule 方式：

```bash
git submodule update --remote
.githooks/install.sh
```

## 🎯 最佳实践

1. **使用 .env 文件**
   ```bash
   # .env (添加到 .gitignore)
   PRIVATE_KEY=0x1234...
   API_KEY=sk-1234...
   ```

2. **提供 .env.example**
   ```bash
   # .env.example (可以提交)
   PRIVATE_KEY=
   API_KEY=
   ```

3. **在 README 中说明**
   ```markdown
   ## Setup
   1. Copy `.env.example` to `.env`
   2. Fill in your credentials
   3. Never commit `.env` file
   ```

4. **定期审计**
   ```bash
   # 使用 git-secrets 扫描历史
   git secrets --scan-history
   
   # 使用 truffleHog 查找泄露
   trufflehog git file://. --only-verified
   ```

## 🆘 故障排除

### Hook 没有运行？

```bash
# 检查 hook 是否存在
ls -la .git/hooks/pre-commit

# 检查是否可执行
chmod +x .git/hooks/pre-commit

# 测试 hook
.git/hooks/pre-commit
```

### GitHub Action 失败？

1. 检查 workflow 文件路径：`.github/workflows/check-secrets.yml`
2. 查看 Actions 日志获取详细错误信息
3. 确保 repository 启用了 GitHub Actions

### 误报问题？

如果某些内容被错误标记：

1. 检查是否是实际的密钥值
2. 使用注释说明这是示例：`// Example key (not real)`
3. 将文件添加到排除列表

## 📚 相关资源

- [详细复用指南](./docs/pre-commit-hook-reuse-guide.md)
- [Git Hooks 官方文档](https://git-scm.com/docs/githooks)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [git-secrets](https://github.com/awslabs/git-secrets)
- [truffleHog](https://github.com/trufflesecurity/trufflehog)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**记住：永远不要提交真实的私钥和敏感信息！** 🔐
