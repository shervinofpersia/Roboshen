#!/bin/bash

# ==========================================
# ROBOSHΞN™ - Automated Setup for Termux
# ==========================================

# رنگ‌ها برای زیباتر شدن خروجی ترمینال
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}   Welcome to ROBOSHΞN™ Installer   ${NC}"
echo -e "${BLUE}======================================${NC}"

# ۱. نصب پیش‌نیازهای سیستمی
echo -e "\n${YELLOW}[1/4] Updating packages and installing dependencies...${NC}"
pkg update -y && pkg upgrade -y
pkg install git python curl wget ncurses-utils -y

# ۲. تنظیمات فونت فارسی برای ترموکس
echo -e "\n${YELLOW}[2/4] Setting up Persian font natively for Termux...${NC}"
mkdir -p ~/.termux

# دانلود مستقیم فونت وزیر در مسیر اختصاصی ترموکس
echo -e "Downloading Vazir font..."
curl -sL -o ~/.termux/font.ttf https://github.com/rastikerdar/vazir-font/raw/master/dist/Vazir.ttf

# رفرش کردن تنظیمات ترموکس برای اعمال آنی فونت
if command -v termux-reload-settings &>/dev/null; then
    termux-reload-settings
    echo -e "${GREEN}✔ Font applied successfully!${NC}"
else
    echo -e "${RED}⚠ Could not automatically reload Termux settings. You may need to restart the app.${NC}"
fi

# ۳. دریافت سورس کد پروژه
echo -e "\n${YELLOW}[3/4] Downloading Roboshen project...${NC}"
cd ~
if [ -d "Roboshen" ]; then
    echo -e "Removing old version..."
    rm -rf Roboshen
fi

git clone https://github.com/shervinofpersia/Roboshen.git
cd Roboshen

# ۴. نصب کتابخانه‌های پایتون
echo -e "\n${YELLOW}[4/4] Installing Python requirements...${NC}"
# استفاده از --break-system-packages برای دور زدن محدودیت‌های PEP 668 در ترموکس
pip install -r requirements.txt --break-system-packages

# ۵. پایان و اجرای ربات
echo -e "\n${BLUE}======================================${NC}"
echo -e "${GREEN}   Installation Complete! 🎉        ${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "Starting ROBOSHΞN™...\n"

# اجرای مستقیم پایتون
python roboshen.py
