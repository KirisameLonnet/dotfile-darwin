#!/bin/bash

# Gemini CLI 使用示例

echo "🤖 Gemini CLI 使用示例"
echo "====================="

# 检查 API 密钥
if [ -z "$GEMINI_API_KEY" ] && [ ! -f ~/.gemini/.env ]; then
    echo "❌ 请先设置 API 密钥"
    echo "运行: ~/.config/nixconfig/config/gemini/setup-gemini.sh"
    exit 1
fi

echo "✅ API 密钥已配置"
echo ""

# 基本对话示例
echo "📝 基本对话示例:"
echo "$ gemini"
echo "> 什么是 Nix？"
echo ""
echo "$ npx @google/gemini-cli"
echo "> 解释一下 macOS 的窗口管理器"
echo ""

# 代码相关示例
echo "💻 代码相关示例:"
echo "$ cd your-project/"
echo "$ gemini"
echo "> 描述这个系统的主要架构组件"
echo "> 为 GitHub issue #123 实现一个初始草案"
echo "> 帮我把这个代码库迁移到最新的 Java 版本"
echo ""

# 系统操作示例
echo "� 系统操作示例:"
echo "$ gemini"
echo "> 把这个目录中的所有图片转换为 PNG 格式，并使用 EXIF 数据中的日期重命名"
echo "> 按支出月份整理我的 PDF 发票"
echo "> 创建一个 shell 脚本来自动化我的日常开发工作流"
echo ""

# 项目分析示例
echo "� 项目分析示例:"
echo "$ cd my-project/"
echo "$ gemini"
echo "> 分析这个项目的代码结构"
echo "> 找出可能的性能瓶颈"
echo "> 建议如何改进测试覆盖率"
echo "> 生成项目的技术文档"
echo ""

# 学习和研究示例
echo "📚 学习和研究示例:"
echo "$ gemini"
echo "> 解释 React Hooks 的工作原理"
echo "> 比较 TypeScript 和 JavaScript 的优缺点"
echo "> 创建一个 GraphQL 学习计划"
echo ""

# 实用技巧
echo "💡 实用技巧:"
echo "1. 使用 'cd project-dir && gemini' 让 AI 了解项目上下文"
echo "2. 在对话中提供具体的文件路径和代码片段"
echo "3. 使用 ~/.gemini/.env 文件管理 API 密钥"
echo "4. 利用 Gemini 的多模态能力处理图片和文档"
echo "5. 通过具体的任务描述获得更好的结果"
echo ""

echo "📚 更多帮助:"
echo "$ gemini-helpers.sh help"
echo "$ cat ~/.config/nixconfig/config/gemini/README.md"
