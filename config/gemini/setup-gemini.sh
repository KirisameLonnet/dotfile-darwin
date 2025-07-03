#!/bin/bash

# Gemini CLI 快速设置脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Gemini CLI 配置设置${NC}"
echo "================================="

# 检查 Node.js 版本
echo -e "${YELLOW}检查 Node.js 版本...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    echo "请运行: darwin-rebuild switch --flake ~/.config/nixconfig"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2)
NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo -e "${RED}❌ Node.js 版本过低 (需要 >= 18, 当前: $NODE_VERSION)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js 版本: $NODE_VERSION${NC}"

# 检查 npm
echo -e "${YELLOW}检查 npm...${NC}"
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm 未安装${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm 可用${NC}"

# 安装 Gemini CLI
echo -e "${YELLOW}安装 Gemini CLI...${NC}"
if ! command -v gemini &> /dev/null; then
    echo -e "${YELLOW}正在安装 @google/gemini-cli...${NC}"
    npm install -g @google/gemini-cli
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Gemini CLI 安装成功${NC}"
    else
        echo -e "${RED}❌ Gemini CLI 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Gemini CLI 已安装${NC}"
fi

# 检查 API 密钥
echo -e "${YELLOW}检查 API 密钥配置...${NC}"
if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  GEMINI_API_KEY 环境变量未设置${NC}"
    echo ""
    echo "请按照以下步骤设置 API 密钥："
    echo "1. 访问 https://aistudio.google.com/app/apikey 获取 API 密钥"
    echo "2. 选择配置方式："
    echo ""
    echo -e "${BLUE}选项 1: 创建 ~/.gemini/.env 文件 (推荐)${NC}"
    echo "   mkdir -p ~/.gemini"
    echo "   echo 'GEMINI_API_KEY=\"your-api-key-here\"' > ~/.gemini/.env"
    echo ""
    echo -e "${BLUE}选项 2: 添加到 shell 配置文件${NC}"
    echo "   echo 'export GEMINI_API_KEY=\"your-api-key-here\"' >> ~/.zshrc_local"
    echo "   source ~/.zshrc_local"
    echo ""
    
    read -p "是否现在设置 API 密钥? (y/n): " setup_key
    if [[ $setup_key =~ ^[Yy]$ ]]; then
        read -p "请输入您的 Gemini API 密钥: " api_key
        if [ ! -z "$api_key" ]; then
            # 创建 .gemini 目录和环境文件
            mkdir -p ~/.gemini
            echo "GEMINI_API_KEY=\"$api_key\"" > ~/.gemini/.env
            echo ""
            echo -e "${GREEN}✅ API 密钥已保存到 ~/.gemini/.env${NC}"
            echo "配置立即生效，无需重新加载 shell"
        fi
    fi
else
    echo -e "${GREEN}✅ API 密钥已配置${NC}"
fi

# 创建 .gemini 目录结构
echo -e "${YELLOW}设置 Gemini CLI 配置目录...${NC}"
mkdir -p ~/.gemini
if [ ! -f ~/.gemini/.env ] && [ ! -z "$GEMINI_API_KEY" ]; then
    echo "GEMINI_API_KEY=\"$GEMINI_API_KEY\"" > ~/.gemini/.env
    echo -e "${GREEN}✅ 从环境变量创建 ~/.gemini/.env${NC}"
fi

# 测试连接
echo -e "${YELLOW}测试 Gemini CLI 连接...${NC}"
if [ ! -z "$GEMINI_API_KEY" ] || [ -f ~/.gemini/.env ]; then
    echo "正在测试 Gemini CLI..."
    if timeout 10 gemini --help &>/dev/null; then
        echo -e "${GREEN}✅ Gemini CLI 可用${NC}"
    else
        echo -e "${YELLOW}⚠️  Gemini CLI 测试失败，请检查配置${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  跳过连接测试（API 密钥未设置）${NC}"
fi

echo ""
echo -e "${BLUE}🎉 Gemini CLI 配置完成！${NC}"
echo "================================="
echo ""
echo "使用方法："
echo -e "${GREEN}# 启动 Gemini CLI${NC}"
echo "gemini"
echo ""
echo -e "${GREEN}# 或使用 npx (无需安装)${NC}"
echo "npx @google/gemini-cli"
echo ""
echo "相关资源："
echo "- 官方文档: https://github.com/google-gemini/gemini-cli"
echo "- API 密钥管理: https://aistudio.google.com/app/apikey"
echo "- 配置文件: ~/.gemini/.env"
echo ""
echo -e "${YELLOW}提示：如果遇到问题，请查看 README.md 文件或运行此脚本重新配置${NC}"
echo -e "${GREEN}🎉 设置完成！${NC}"
echo ""
echo -e "${YELLOW}快速开始:${NC}"
echo "  gm \"你好\"                    # 基本对话"
echo "  gmi                          # 交互模式"
echo "  ai                           # AIChat 交互"
echo "  aic \"写一个 Python 函数\"    # 代码模式"
echo "  code-review                  # 代码审查"
echo "  gen-commit                   # 生成提交消息"
echo ""
echo -e "${YELLOW}更多帮助:${NC}"
echo "  查看文档: cat ~/.config/nixconfig/config/gemini/README.md"
echo "  查看帮助: ~/.config/nixconfig/config/gemini/gemini-helpers.sh help"
echo ""
echo -e "${BLUE}祝您使用愉快！${NC}"
