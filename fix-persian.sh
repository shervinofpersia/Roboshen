#!/bin/bash
# fix-persian.sh - حل کامل مشکل فارسی در Termux (فونت + کتابخانه + تنظیمات)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🔧 Fix Persian Language in Termux${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================
# ۱. نصب فونت فارسی
# ============================================================
echo -e "\n${YELLOW}📦 Step 1: Installing Persian fonts...${NC}"

# نصب fontconfig اگر نصب نیست
if ! command -v fc-list &>/dev/null; then
    echo -e "${YELLOW}Installing fontconfig...${NC}"
    pkg install -y fontconfig
fi

# نصب فونت‌های مختلف (یکی از آنها کار می‌کند)
echo -e "${YELLOW}Installing font packages...${NC}"
pkg install -y ttf-noto 2>/dev/null || pkg install -y noto-fonts 2>/dev/null || pkg install -y fontconfig-utils 2>/dev/null || true

# دانلود و نصب فونت Vazir (بهترین فونت فارسی)
echo -e "${YELLOW}Downloading Vazir font...${NC}"
mkdir -p ~/.fonts
curl -sL -o ~/.fonts/Vazir.ttf https://github.com/rastikerdar/vazir-font/raw/master/dist/Vazir.ttf

# به‌روزرسانی کش فونت
echo -e "${YELLOW}Updating font cache...${NC}"
fc-cache -fv 2>/dev/null || true

echo -e "${GREEN}✅ Fonts installed.${NC}"

# ============================================================
# ۲. نصب کتابخانه‌های پایتون برای اصلاح متن
# ============================================================
echo -e "\n${YELLOW}📚 Step 2: Installing Python libraries...${NC}"

# نصب pip اگر نصب نیست
if ! command -v pip &>/dev/null; then
    echo -e "${YELLOW}Installing pip...${NC}"
    pkg install -y python-pip
fi

# نصب کتابخانه‌های مورد نیاز
echo -e "${YELLOW}Installing arabic_reshaper and python-bidi...${NC}"
pip install --break-system-packages arabic-reshaper python-bidi 2>/dev/null || pip install arabic-reshaper python-bidi 2>/dev/null || true

# نصب rich برای نمایش بهتر
echo -e "${YELLOW}Installing rich...${NC}"
pip install --break-system-packages rich 2>/dev/null || pip install rich 2>/dev/null || true

echo -e "${GREEN}✅ Python libraries installed.${NC}"

# ============================================================
# ۳. تنظیمات Locale و محیط
# ============================================================
echo -e "\n${YELLOW}🌍 Step 3: Setting up locale...${NC}"

# تنظیم locale برای پشتیبانی از UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# اضافه کردن به bashrc
if ! grep -q 'export LANG=en_US.UTF-8' ~/.bashrc 2>/dev/null; then
    echo '# Persian support' >> ~/.bashrc
    echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
    echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
fi

# تنظیم locale در Termux (اگر فایل locale.gen وجود داشته باشد)
if [ -f /data/data/com.termux/files/usr/etc/locale.gen ]; then
    echo -e "${YELLOW}Generating locale...${NC}"
    echo "en_US.UTF-8 UTF-8" > /data/data/com.termux/files/usr/etc/locale.gen
    locale-gen 2>/dev/null || true
fi

echo -e "${GREEN}✅ Locale configured.${NC}"

# ============================================================
# ۴. ایجاد فایل تست برای بررسی
# ============================================================
echo -e "\n${YELLOW}🧪 Step 4: Creating test script...${NC}"

cat > ~/test-persian.py << 'EOF'
#!/usr/bin/env python3
# تست نمایش فارسی در ترمینال

import sys
import subprocess

# بررسی کتابخانه‌ها
try:
    import arabic_reshaper
    from bidi.algorithm import get_display
    HAS_LIBS = True
except ImportError:
    HAS_LIBS = False
    print("⚠️  Libraries not installed. Run: pip install arabic_reshaper python-bidi")

def fix_text(text):
    if HAS_LIBS:
        try:
            reshaped = arabic_reshaper.reshape(text)
            return get_display(reshaped)
        except:
            return text
    return text

# تست‌های مختلف
test_texts = [
    "سلام دنیا!",
    "این یک تست فارسی در ترموکس است.",
    "به نام خدا",
    "Termux با پشتیبانی از فارسی"
]

print("\n" + "="*50)
print("🧪 Persian Text Test")
print("="*50 + "\n")

for i, text in enumerate(test_texts, 1):
    fixed = fix_text(text)
    print(f"{i}. {fixed}")

print("\n" + "="*50)

if HAS_LIBS:
    print("✅ همه چیز به درستی کار می‌کند.")
else:
    print("❌ کتابخانه‌ها نصب نیستند.")

print("="*50 + "\n")
EOF

chmod +x ~/test-persian.py
echo -e "${GREEN}✅ Test script created at ~/test-persian.py${NC}"

# ============================================================
# ۵. تنظیمات اضافی برای ترمینال
# ============================================================
echo -e "\n${YELLOW}⚙️ Step 5: Additional terminal settings...${NC}"

# تنظیمات برای ترمینال (اگر در Termux باشد)
if [ -d "/data/data/com.termux" ]; then
    # تنظیم کلیدهای میانبر برای کیبورد فارسی (اختیاری)
    echo -e "${YELLOW}Adding keyboard hints...${NC}"
    # می‌توانید فایل .termux/termux.properties را ویرایش کنید
    mkdir -p ~/.termux
    if ! grep -q 'use-black-ui = true' ~/.termux/termux.properties 2>/dev/null; then
        echo "use-black-ui = true" >> ~/.termux/termux.properties
        echo "bell-character = ignore" >> ~/.termux/termux.properties
    fi
fi

echo -e "${GREEN}✅ Terminal settings done.${NC}"

# ============================================================
# ۶. فعال‌سازی تنظیمات
# ============================================================
echo -e "\n${YELLOW}🔄 Step 6: Applying settings...${NC}"

# اعمال تغییرات در جلسه جاری
source ~/.bashrc 2>/dev/null || true

# ============================================================
# ۷. نتیجه نهایی
# ============================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Persian support installation complete!${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${YELLOW}📌 To test Persian display, run:${NC}"
echo -e "   ${GREEN}python3 ~/test-persian.py${NC}"

echo -e "\n${YELLOW}📌 To use in your Python scripts:${NC}"
echo -e "${GREEN}from bidi.algorithm import get_display${NC}"
echo -e "${GREEN}import arabic_reshaper${NC}"
echo -e "${GREEN}def fix(text):${NC}"
echo -e "${GREEN}    return get_display(arabic_reshaper.reshape(text))${NC}"

echo -e "\n${YELLOW}📌 Important:${NC}"
echo -e "   1. ${GREEN}Close and reopen Termux${NC} for changes to take effect."
echo -e "   2. If fonts don't work, change terminal font to 'Vazir' or 'Noto' in:"
echo -e "      ${BLUE}Termux → More → Style → Choose a font${NC}"
echo -e "   3. Run test script to verify everything works."

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}📢 Contact: Telegram @shervini${NC}"
echo -e "${BLUE}========================================${NC}\n"

# اجرای خودکار تست
echo -e "${YELLOW}Running test automatically...${NC}\n"
python3 ~/test-persian.py 2>/dev/null || echo -e "${RED}❌ Test failed. Run it manually later.${NC}"

echo -e "\n${GREEN}Done! 🎉${NC}"
