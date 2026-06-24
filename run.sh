#!/bin/bash
# run.sh - یک‌بار نصب و اجرای ROBOSHΞN™

set -e

# نصب فایل‌ها
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

curl -sL -o requirements.txt https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/requirements.txt
curl -sL -o roboshen.py https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/roboshen.py

# نصب پیش‌نیازها (فقط در صورتی که نصب نشده باشند)
if ! command -v python3 &>/dev/null; then
    if [ -d "/data/data/com.termux" ]; then
        pkg install -y python3 python-pip
    else
        sudo apt install -y python3 python3-pip
    fi
fi

# نصب کتابخانه‌ها
if [ -d "/data/data/com.termux" ]; then
    python3 -m pip install --break-system-packages -r requirements.txt 2>/dev/null || true
else
    pip3 install -r requirements.txt 2>/dev/null || true
fi

# نصب فونت (اختیاری)
if ! fc-list :lang=fa | grep -q . 2>/dev/null; then
    if [ -d "/data/data/com.termux" ]; then
        pkg install -y fontconfig ttf-noto 2>/dev/null || true
    else
        sudo apt install -y fonts-noto fontconfig 2>/dev/null || true
    fi
fi

# نصب اسکریپت در مسیر
mkdir -p ~/.local/bin
cp roboshen.py ~/.local/bin/roboshen
chmod +x ~/.local/bin/roboshen

# تنظیم PATH (برای همین جلسه)
export PATH="$HOME/.local/bin:$PATH"

# پاکسازی
cd ~
rm -rf "$TMP_DIR"

# اجرا
clear
echo -e "\033[0;32m🤖 ROBOSHΞN™ started...\033[0m"
echo -e "\033[0;32m📢 Contact: Telegram @shervini\033[0m\n"
~/.local/bin/roboshen
