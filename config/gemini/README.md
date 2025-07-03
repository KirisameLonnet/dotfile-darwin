# Gemini CLI 配置指南

## 概述
Gemini CLI 是 Google 官方的命令行 AI 工具，可以直接在终端中使用 Google Gemini AI。

## 安装
通过 npm 全局安装：
```bash
npm install -g @google/gemini-cli
```

或者使用 npx 运行：
```bash
npx @google/gemini-cli
```

## 前提条件
- Node.js 18 或更高版本（已通过 Nix 安装）

## 认证设置

### 方法 1: Gemini API 密钥 (推荐)
1. 访问 [Google AI Studio](https://aistudio.google.com/app/apikey) 获取 API 密钥
2. 设置环境变量：

```bash
export GEMINI_API_KEY="your-api-key-here"
```

### 方法 2: Google 账户登录
```bash
gemini  # 首次运行会提示登录
```

### 方法 3: Google Cloud/Vertex AI
```bash
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="us-central1"
export GOOGLE_GENAI_USE_VERTEXAI=true
```

## 配置文件

### .env 文件配置
Gemini CLI 会自动加载 `.env` 文件，搜索顺序：
1. 当前目录及其父目录中的 `.gemini/.env` 或 `.env`
2. 家目录中的 `~/.gemini/.env` 或 `~/.env`

**项目级配置**：
```bash
mkdir -p .gemini
echo 'GEMINI_API_KEY="your-api-key-here"' > .gemini/.env
```

**用户级配置**：
```bash
mkdir -p ~/.gemini
cat > ~/.gemini/.env <<EOF
GEMINI_API_KEY="your-api-key-here"
GOOGLE_CLOUD_PROJECT="your-project-id"
EOF
```

## 使用方法

### 基本使用
```bash
# 进入项目目录
cd your-project/
gemini

# 或者直接使用 npx
npx @google/gemini-cli
```

### 常见用例

#### 代码分析
```bash
gemini
> 描述这个系统的主要架构组件
> 这里有什么安全机制？
```

#### 代码开发
```bash
> 为 GitHub issue #123 实现一个初始草案
> 帮我把这个代码库迁移到最新的 Java 版本，从制定计划开始
```

#### 系统操作
```bash
> 把这个目录中的所有图片转换为 PNG 格式，并使用 EXIF 数据中的日期重命名
> 按支出月份整理我的 PDF 发票
```

## 故障排除

### 常见问题
1. **Node.js 版本问题**：确保 Node.js 版本 >= 18
2. **认证问题**：检查 API 密钥是否正确设置
3. **网络问题**：确保能访问 Google AI 服务

### 检查配置
```bash
# 检查 Node.js 版本
node --version

# 检查环境变量
echo $GEMINI_API_KEY

# 检查 .env 文件
cat ~/.gemini/.env
```

## 卸载
```bash
npm uninstall -g @google/gemini-cli
```

## 相关链接
- [官方文档](https://github.com/google-gemini/gemini-cli)
- [Google AI Studio](https://aistudio.google.com/app/apikey)
- [故障排除指南](https://github.com/google-gemini/gemini-cli/blob/main/docs/troubleshooting.md)
- [CLI 命令参考](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/commands.md)
