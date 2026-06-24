#!/bin/bash
# install.sh – نصب خودکار ROBOSHΞN™

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🤖 شروع نصب ROBOSHΞN™...${NC}"

# تشخیص محیط (Termux یا Linux معمولی)
if [ -d "/data/data/com.termux" ]; then
    echo -e "${YELLOW}📱 محیط Termux تشخیص داده شد.${NC}"
    PKG_MANAGER="pkg"
    INSTALL_CMD="pkg install -y"
    IS_TERMUX=true
else
    echo -e "${YELLOW}🐧 محیط Linux تشخیص داده شد.${NC}"
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    IS_TERMUX=false
fi

# نصب پایتون و ابزارهای لازم
echo -e "${YELLOW}📦 بررسی و نصب پیش‌نیازهای سیستمی...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}پایتون ۳ یافت نشد. در حال نصب...${NC}"
    $INSTALL_CMD python3
fi

# در Termux، پایتون به همراه pip نصب می‌شود
if [ "$IS_TERMUX" = true ]; then
    # اطمینان از نصب python-pip
    if ! command -v pip &> /dev/null; then
        echo -e "${YELLOW}نصب python-pip...${NC}"
        $INSTALL_CMD python-pip
    fi
else
    if ! command -v pip3 &> /dev/null; then
        echo -e "${YELLOW}نصب pip3...${NC}"
        $INSTALL_CMD python3-pip
    fi
fi

# نصب کتابخانه‌های پایتون از requirements.txt
echo -e "${YELLOW}📚 نصب کتابخانه‌های پایتون...${NC}"
if [ "$IS_TERMUX" = true ]; then
    # در Termux از --break-system-packages استفاده می‌کنیم
    python3 -m pip install --break-system-packages -r requirements.txt
else
    pip3 install -r requirements.txt
fi

# نصب فونت فارسی (فقط در صورتی که نصب نباشه)
echo -e "${YELLOW}🖋️ بررسی فونت فارسی...${NC}"
if ! fc-list :lang=fa | grep -q .; then
    echo -e "${YELLOW}فونت فارسی یافت نشد. در حال نصب...${NC}"
    if [ "$IS_TERMUX" = true ]; then
        $INSTALL_CMD fontconfig noto-fonts
    else
        $INSTALL_CMD fonts-noto fontconfig
    fi
else
    echo -e "${GREEN}✅ فونت فارسی موجود است.${NC}"
fi

# نصب اسکریپت اصلی در مسیر PATH
TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"
cp roboshen.py "$TARGET_DIR/roboshen"
chmod +x "$TARGET_DIR/roboshen"

# افزودن به PATH اگر قبلاً اضافه نشده
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
    echo -e "${YELLOW}⚠️ مسیر $HOME/.local/bin به PATH اضافه شد. لطفاً ترمینال را مجدداً باز کنید یا دستور زیر را اجرا کنید:${NC}"
    echo -e "   ${GREEN}source $SHELL_CONFIG${NC}"
fi

echo -e "${GREEN}✅ نصب ROBOSHΞN™ با موفقیت انجام شد.${NC}"
echo -e "💡 حالا با دستور ${GREEN}roboshen${NC} می‌توانید آن را اجرا کنید."
echo -e "📢 برای ارتباط با سازنده: ${GREEN}Telegram @shervini${NC}"
