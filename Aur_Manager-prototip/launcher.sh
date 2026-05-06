#!/bin/bash

# AUR Manager Launcher
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Python kontrolü
if ! command -v python3 &> /dev/null; then
    zenity --error --text="Python 3 kurulu değil!\n\nLütfen önce installer.sh çalıştırın." 2>/dev/null || \
    notify-send "AUR Manager" "Python 3 kurulu değil! Lütfen önce installer.sh çalıştırın." 2>/dev/null || \
    echo "❌ Python 3 kurulu değil! Lütfen önce installer.sh çalıştırın."
    exit 1
fi

# PyQt5 kontrolü
if ! python3 -c "from PyQt5.QtWidgets import QApplication" &> /dev/null; then
    zenity --error --text="PyQt5 kurulu değil!\n\nLütfen önce installer.sh çalıştırın." 2>/dev/null || \
    notify-send "AUR Manager" "PyQt5 kurulu değil! Lütfen önce installer.sh çalıştırın." 2>/dev/null || \
    echo "❌ PyQt5 kurulu değil! Lütfen önce installer.sh çalıştırın."
    exit 1
fi

# Ana uygulamayı başlat
python3 "$SCRIPT_DIR/aur_gui.py"
