#!/bin/bash
# install.sh - ROBOSHΞN™ auto installer for Termux/Linux

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}ROBOSHΞN™ installation started...${NC}"

# detect environment
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
    PKG_CMD="pkg install -y"
else
    IS_TERMUX=false
    PKG_CMD="sudo apt install -y"
fi

# install python & pip if missing
if ! command -v python3 &>/dev/null; then
    echo -e "${YELLOW}Installing python3...${NC}"
    $PKG_CMD python3
fi

if [ "$IS_TERMUX" = true ]; then
    if ! command -v pip &>/dev/null; then
        echo -e "${YELLOW}Installing python-pip...${NC}"
        $PKG_CMD python-pip
    fi
    PYTHON="python3"
    PIP="$PYTHON -m pip"
else
    if ! command -v pip3 &>/dev/null; then
        echo -e "${YELLOW}Installing pip3...${NC}"
        $PKG_CMD python3-pip
    fi
    PYTHON="python3"
    PIP="pip3"
fi

# create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# download required files from GitHub
echo -e "${YELLOW}Downloading files from GitHub...${NC}"
curl -sL -o requirements.txt https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/requirements.txt
curl -sL -o roboshen.py https://raw.githubusercontent.com/shervinofpersia/Roboshen/main/roboshen.py

# install python packages
echo -e "${YELLOW}Installing required python packages...${NC}"
if [ "$IS_TERMUX" = true ]; then
    $PIP install --break-system-packages -r requirements.txt
else
    $PIP install -r requirements.txt
fi

# install persian font if missing (with fallback for Termux)
echo -e "${YELLOW}Checking Persian font...${NC}"
if ! fc-list :lang=fa | grep -q .; then
    echo -e "${YELLOW}Persian font not found. Attempting to install...${NC}"
    if [ "$IS_TERMUX" = true ]; then
        # Try different possible package names in Termux
        if pkg show ttf-noto &>/dev/null; then
            $PKG_CMD ttf-noto
        elif pkg show noto-fonts &>/dev/null; then
            $PKG_CMD noto-fonts
        else
            echo -e "${YELLOW}No font package available. Installing fontconfig only.${NC}"
            $PKG_CMD fontconfig
            echo -e "${YELLOW}You may need to install a Persian font manually.${NC}"
        fi
    else
        $PKG_CMD fonts-noto fontconfig
    fi
else
    echo -e "${GREEN}Font already installed.${NC}"
fi

# install script to ~/.local/bin
TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"
cp roboshen.py "$TARGET_DIR/roboshen"
chmod +x "$TARGET_DIR/roboshen"

# add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ] && SHELL_CONFIG="$HOME/.zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
    echo -e "${YELLOW}Added ~/.local/bin to PATH. Please restart terminal or run: source $SHELL_CONFIG${NC}"
fi

# cleanup
cd ~
rm -rf "$TMP_DIR"

echo -e "${GREEN}Installation complete. Run 'roboshen' to start.${NC}"
echo -e "Contact: Telegram @shervini"
