#!/bin/bash
# run.sh - یک‌بار نصب، رفع فونت و اجرای ROBOSHΞN™

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🤖 ROBOSHΞN™ installation started...${NC}"

# ===== ۱. نصب پایتون =====
if ! command -v python3 &>/dev/null; then
    echo -e "${YELLOW}Installing Python...${NC}"
    if [ -d "/data/data/com.termux" ]; then
        pkg install -y python3 python-pip
    else
        sudo apt install -y python3 python3-pip
    fi
fi

# ===== ۲. نصب فونت فارسی =====
echo -e "${YELLOW}Installing Persian font...${NC}"
if [ -d "/data/data/com.termux" ]; then
    # نصب فونت در Termux
    pkg install -y fontconfig ttf-noto 2>/dev/null || pkg install -y fontconfig noto-fonts 2>/dev/null || true
    mkdir -p ~/.fonts
    curl -sL -o ~/.fonts/Vazir.ttf https://github.com/rastikerdar/vazir-font/raw/master/dist/Vazir.ttf
    fc-cache -fv 2>/dev/null || true
    # تنظیم locale
    if ! grep -q 'export LANG=en_US.UTF-8' ~/.bashrc; then
        echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
        echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
    fi
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
else
    # لینوکس معمولی
    sudo apt install -y fonts-noto fontconfig
fi

# ===== ۳. نصب کتابخانه‌های پایتون =====
echo -e "${YELLOW}Installing Python packages...${NC}"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

curl -sL -o requirements.txt https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/requirements.txt
curl -sL -o roboshen.py https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/roboshen.py

if [ -d "/data/data/com.termux" ]; then
    python3 -m pip install --break-system-packages -r requirements.txt 2>/dev/null || true
else
    pip3 install -r requirements.txt 2>/dev/null || true
fi

# ===== ۴. نصب اسکریپت =====
mkdir -p ~/.local/bin
cp roboshen.py ~/.local/bin/roboshen
chmod +x ~/.local/bin/roboshen

# تنظیم PATH برای همین جلسه
export PATH="$HOME/.local/bin:$PATH"
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# ===== ۵. پاکسازی =====
cd ~
rm -rf "$TMP_DIR"

# ===== ۶. اجرا =====
clear
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}▶️  ROBOSHΞN™ is starting...${NC}"
echo -e "${YELLOW}📢 Contact: Telegram @shervini${NC}\n"
sleep 1

# اجرای برنامه
~/.local/bin/roboshen
