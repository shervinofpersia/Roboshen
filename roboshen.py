#!/bin/bash
# install.sh – نصب خودکار ROBOSHΞN™

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🤖 شروع نصب ROBOSHΞN™...${NC}"

# تشخیص محیط (Termux یا Linux معمولی)
if [ -d "/data/data/com.termux" ]; then
    echo -e "${YELLOW}📱 محیط Termux تشخیص داده شد.${NC}"
    PKG_MANAGER="pkg"
    INSTALL_CMD="pkg install -y"
else
    echo -e "${YELLOW}🐧 محیط Linux تشخیص داده شد.${NC}"
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
fi

# نصب پایتون و ابزارهای لازم (اگر موجود نباشند)
echo -e "${YELLOW}📦 بررسی و نصب پیش‌نیازهای سیستمی...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}پایتون ۳ یافت نشد. در حال نصب...${NC}"
    $INSTALL_CMD python3 python3-pip
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}pip3 یافت نشد. در حال نصب...${NC}"
    $INSTALL_CMD python3-pip
fi

# نصب کتابخانه‌های پایتون از requirements.txt
echo -e "${YELLOW}📚 نصب کتابخانه‌های پایتون...${NC}"
pip3 install --upgrade pip
pip3 install -r requirements.txt

# نصب فونت فارسی (فقط در صورتی که نصب نباشه)
echo -e "${YELLOW}🖋️ بررسی فونت فارسی...${NC}"
if ! fc-list :lang=fa | grep -q .; then
    echo -e "${YELLOW}فونت فارسی یافت نشد. در حال نصب...${NC}"
    if [ -d "/data/data/com.termux" ]; then
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
cp roboshn.py "$TARGET_DIR/roboshn"
chmod +x "$TARGET_DIR/roboshn"

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
echo -e "💡 حالا با دستور ${GREEN}roboshn${NC} می‌توانید آن را اجرا کنید."
echo -e "📢 برای ارتباط با سازنده: ${GREEN}Telegram @shervini${NC}"
