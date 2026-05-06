#!/bin/bash

# AUR Manager - Tamamen Kaldırma Scripti
# Tüm dosyaları, yapılandırmaları ve bağımlılıkları temizler

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}"
echo "════════════════════════════════════════════════════════"
echo "        🗑️  AUR Manager - Tamamen Kaldırma"
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"

# Uyarı
echo -e "${RED}⚠️  DİKKAT! Bu işlem şunları tamamen silecektir:${NC}"
echo "   • AUR Manager uygulama dosyaları"
echo "   • Yapılandırma dosyaları (~/.config/aur-gui/)"
echo "   • Masaüstü kısayolları"
echo "   • Geçici dosyalar"
echo ""
echo -e "${YELLOW}NOT: Python, PyQt5, paru/yay gibi bağımlılıklar KALDIRILMAYACAK${NC}"
echo "      (çünkü diğer uygulamalar da kullanıyor olabilir)"
echo ""

read -p "Silmek istediğinize emin misiniz? (evet/HAYIR): " confirm

if [ "$confirm" != "evet" ]; then
    echo -e "${GREEN}İptal edildi. Hiçbir şey silinmedi.${NC}"
    exit 0
fi

echo -e "\n${BLUE}🧹 Temizlik başlıyor...${NC}\n"

# 1. Proje dosyalarını sil
echo -e "${YELLOW}1. Proje dosyaları siliniyor...${NC}"
PROJECT_DIR="$HOME/aur-gui"

if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo -e "${GREEN}   ✅ Silindi: $PROJECT_DIR${NC}"
else
    echo -e "${BLUE}   ℹ️  Proje dizini bulunamadı${NC}"
fi

# 2. Config dosyalarını sil
echo -e "\n${YELLOW}2. Yapılandırma dosyaları siliniyor...${NC}"
CONFIG_DIR="$HOME/.config/aur-gui"

if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo -e "${GREEN}   ✅ Silindi: $CONFIG_DIR${NC}"
else
    echo -e "${BLUE}   ℹ️  Config dizini bulunamadı${NC}"
fi

# 3. Desktop dosyalarını sil
echo -e "\n${YELLOW}3. Masaüstü kısayolları siliniyor...${NC}"
DESKTOP_FILE1="$HOME/.local/share/applications/aur-manager.desktop"
DESKTOP_FILE2="$HOME/.local/share/applications/aur-manager-fixed.desktop"

if [ -f "$DESKTOP_FILE1" ]; then
    rm -f "$DESKTOP_FILE1"
    echo -e "${GREEN}   ✅ Silindi: $DESKTOP_FILE1${NC}"
fi

if [ -f "$DESKTOP_FILE2" ]; then
    rm -f "$DESKTOP_FILE2"
    echo -e "${GREEN}   ✅ Silindi: $DESKTOP_FILE2${NC}"
fi

# 4. Autostart'dan kaldır (varsa)
echo -e "\n${YELLOW}4. Otomatik başlatma girişleri siliniyor...${NC}"
AUTOSTART_FILE="$HOME/.config/autostart/aur-manager.desktop"

if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    echo -e "${GREEN}   ✅ Silindi: $AUTOSTART_FILE${NC}"
else
    echo -e "${BLUE}   ℹ️  Autostart girişi bulunamadı${NC}"
fi

# 5. Geçici dosyaları sil
echo -e "\n${YELLOW}5. Geçici dosyalar siliniyor...${NC}"
TMP_FILES=$(find /tmp -name "*aur*" -o -name "*AUR*" 2>/dev/null)

if [ ! -z "$TMP_FILES" ]; then
    echo "$TMP_FILES" | while read file; do
        rm -rf "$file"
        echo -e "${GREEN}   ✅ Silindi: $file${NC}"
    done
else
    echo -e "${BLUE}   ℹ️  Geçici dosya bulunamadı${NC}"
fi

# 6. Desktop database'i güncelle
echo -e "\n${YELLOW}6. Masaüstü veritabanı güncelleniyor...${NC}"
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
    echo -e "${GREEN}   ✅ Masaüstü veritabanı güncellendi${NC}"
fi

# 7. Kullanıcıya seçenek sun (Python ve bağımlılıklar)
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  Bağımlılıklar hala sistemde duruyor:${NC}"
echo "   • python, python-pyqt5"
echo "   • paru veya yay (AUR helper)"
echo ""
echo -e "${RED}Bu bağımlılıkları da kaldırmak ister misiniz?${NC}"
echo -e "${YELLOW}DİKKAT: Diğer uygulamalar da kullanıyor olabilir!${NC}"
echo ""
echo "1) Sadece AUR Manager'ı kaldır (bağımlılıkları dokunma)"
echo "2) Python ve PyQt5'i de kaldır (DİKKATLİ OL!)"
echo "3) AUR helper'ı da kaldır (paru/yay)"
echo "4) Hepsini kaldır (Python + PyQt5 + AUR helper) - ÇOK DİKKAT!"
echo "5) Hiçbirini kaldırma, çık"

read -p "Seçiminiz (1-5): " dep_choice

case $dep_choice in
    2)
        echo -e "\n${RED}⚠️  Python ve PyQt5 kaldırılıyor...${NC}"
        sudo pacman -Rns --noconfirm python python-pyqt5 2>/dev/null
        echo -e "${GREEN}✅ Python ve PyQt5 kaldırıldı${NC}"
        ;;
    3)
        echo -e "\n${RED}⚠️  AUR helper kaldırılıyor...${NC}"
        if command -v paru &> /dev/null; then
            sudo pacman -Rns --noconfirm paru 2>/dev/null
            echo -e "${GREEN}✅ paru kaldırıldı${NC}"
        fi
        if command -v yay &> /dev/null; then
            sudo pacman -Rns --noconfirm yay 2>/dev/null
            echo -e "${GREEN}✅ yay kaldırıldı${NC}"
        fi
        ;;
    4)
        echo -e "\n${RED}⚠️  TÜM BAĞIMLILIKLAR kaldırılıyor...${NC}"
        sudo pacman -Rns --noconfirm python python-pyqt5 2>/dev/null
        if command -v paru &> /dev/null; then
            sudo pacman -Rns --noconfirm paru 2>/dev/null
        fi
        if command -v yay &> /dev/null; then
            sudo pacman -Rns --noconfirm yay 2>/dev/null
        fi
        echo -e "${GREEN}✅ Tüm bağımlılıklar kaldırıldı${NC}"
        ;;
    1|5)
        echo -e "${GREEN}✅ Sadece AUR Manager kaldırıldı, bağımlılıklar duruyor${NC}"
        ;;
    *)
        echo -e "${RED}Geçersiz seçim, sadece AUR Manager kaldırıldı${NC}"
        ;;
esac

# Özet
echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ AUR Manager TAMAMEN KALDIRILDI!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Silinenler:${NC}"
echo "   • ~/aur-gui/ (tüm proje dosyaları)"
echo "   • ~/.config/aur-gui/ (yapılandırma)"
echo "   • ~/.local/share/applications/aur-manager*.desktop (kısayollar)"
echo "   • ~/.config/autostart/aur-manager.desktop (varsa)"
echo ""
echo -e "${YELLOW}Artık tamamen sıfır kurulum yapabilirsiniz!${NC}"
echo -e "${GREEN}🐧 Tekrar kurmak için: cd ~ && git clone ...${NC}"
echo ""

# İsteğe bağlı: Kabuğu yenile
read -p "Masaüstünü yenilemek ister misiniz? (e/H): " refresh
if [ "$refresh" = "e" ] || [ "$refresh" = "E" ]; then
    # KDE, GNOME, XFCE için yenileme
    if command -v kbuildsycoca5 &> /dev/null; then
        kbuildsycoca5 2>/dev/null
        echo -e "${GREEN}✅ KDE menüsü yenilendi${NC}"
    elif command -v update-desktop-database &> /dev/null; then
        update-desktop-database 2>/dev/null
        echo -e "${GREEN}✅ Masaüstü veritabanı yenilendi${NC}"
    fi
fi

echo -e "\n${GREEN}Hoşçakalın! 🐧${NC}"
