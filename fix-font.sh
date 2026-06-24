#!/bin/bash
# fix-font.sh - حل مشکل فونت فارسی در Termux

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔧 Fixing Persian font for Termux...${NC}"

# نصب فونت‌های مورد نیاز
echo -e "${YELLOW}Installing fonts...${NC}"

# تلاش برای نصب بسته‌های مختلف فونت
if pkg show ttf-noto &>/dev/null; then
    pkg install -y ttf-noto
elif pkg show noto-fonts &>/dev/null; then
    pkg install -y noto-fonts
elif pkg show fontconfig &>/dev/null; then
    pkg install -y fontconfig
fi

# نصب fontconfig اگر نصب نیست
if ! command -v fc-list &>/dev/null; then
    pkg install -y fontconfig
fi

# ایجاد پوشه فونت‌های کاربر
mkdir -p ~/.fonts

# دانلود فونت Vazir (فونت استاندارد فارسی)
echo -e "${YELLOW}Downloading Vazir font...${NC}"
curl -sL -o ~/.fonts/Vazir.ttf https://github.com/rastikerdar/vazir-font/raw/master/dist/Vazir.ttf

# به‌روزرسانی کش فونت
echo -e "${YELLOW}Updating font cache...${NC}"
fc-cache -fv

# تنظیم locale برای پشتیبانی از UTF-8
echo -e "${YELLOW}Setting locale...${NC}"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# اضافه کردن به bashrc برای همیشه
if ! grep -q 'export LANG=en_US.UTF-8' ~/.bashrc; then
    echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
    echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
fi

echo -e "${GREEN}✅ Font fix complete!${NC}"
echo -e "${YELLOW}🆗  Close and reopen your terminal.${NC}"
echo -e "${GREEN}▶️  Then try: roboshen${NC}"
