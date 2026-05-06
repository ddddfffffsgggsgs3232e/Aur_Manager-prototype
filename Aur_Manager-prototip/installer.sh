#!/bin/bash

# AUR Manager - Her Şeyi Otomatik Kuran Script
# Python, PyQt5, base-devel, git, paru/yay - HEPSİ!

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "════════════════════════════════════════════════════════"
echo "           🅰️ AUR Manager - Tam Otomatik Kurulum"
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"

# 1. base-devel kontrol ve kurulum
check_base_devel() {
    echo -e "\n${BLUE}🔧 1. base-devel kontrol ediliyor...${NC}"
    
    if ! pacman -Q base-devel &> /dev/null; then
        echo -e "${YELLOW}⚠️  base-devel bulunamadı! Kuruluyor...${NC}"
        sudo pacman -S --needed --noconfirm base-devel
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ base-devel başarıyla kuruldu!${NC}"
        else
            echo -e "${RED}❌ base-devel kurulumu başarısız!${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ base-devel zaten kurulu${NC}"
    fi
}

# 2. git kontrol ve kurulum
check_git() {
    echo -e "\n${BLUE}🔧 2. git kontrol ediliyor...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  git bulunamadı! Kuruluyor...${NC}"
        sudo pacman -S --needed --noconfirm git
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ git başarıyla kuruldu!${NC}"
        else
            echo -e "${RED}❌ git kurulumu başarısız!${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ git zaten kurulu: $(git --version)${NC}"
    fi
}

# 3. Python kontrol ve kurulum
check_python() {
    echo -e "\n${BLUE}🔧 3. Python kontrol ediliyor...${NC}"
    
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}⚠️  Python 3 bulunamadı! Kuruluyor...${NC}"
        sudo pacman -S --needed --noconfirm python
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Python başarıyla kuruldu!${NC}"
        else
            echo -e "${RED}❌ Python kurulumu başarısız!${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Python zaten kurulu: $(python3 --version)${NC}"
    fi
}

# 4. PyQt5 kontrol ve kurulum
check_pyqt5() {
    echo -e "\n${BLUE}🔧 4. PyQt5 kontrol ediliyor...${NC}"
    
    if ! python3 -c "from PyQt5.QtWidgets import QApplication" &> /dev/null; then
        echo -e "${YELLOW}⚠️  PyQt5 bulunamadı! Kuruluyor...${NC}"
        sudo pacman -S --needed --noconfirm python-pyqt5
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ PyQt5 başarıyla kuruldu!${NC}"
        else
            echo -e "${RED}❌ PyQt5 kurulumu başarısız!${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ PyQt5 zaten kurulu${NC}"
    fi
}

# 5. AUR helper seçimi
choose_aur_helper() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}📦 Hangi AUR yardımcısını kullanmak istersiniz?${NC}"
    echo "1) paru (önerilen - daha hızlı)"
    echo "2) yay (klasik)"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    
    while true; do
        read -p "Seçiminiz (1/2): " choice
        case $choice in
            1) 
                AUR_HELPER="paru"
                break
                ;;
            2)
                AUR_HELPER="yay"
                break
                ;;
            *)
                echo -e "${RED}Geçersiz seçim! Lütfen 1 veya 2 girin.${NC}"
                ;;
        esac
    done
}

# 6. AUR helper kontrol ve kurulum
install_aur_helper() {
    echo -e "\n${BLUE}🔧 5. ${AUR_HELPER} kontrol ediliyor...${NC}"
    
    if ! command -v $AUR_HELPER &> /dev/null; then
        echo -e "${YELLOW}⚠️  ${AUR_HELPER} bulunamadı! Kuruluyor...${NC}"
        
        # Geçici dizin oluştur
        TMP_DIR=$(mktemp -d)
        cd $TMP_DIR
        
        # AUR'dan çek ve kur
        echo -e "${BLUE}📥 ${AUR_HELPER} AUR'dan indiriliyor...${NC}"
        git clone https://aur.archlinux.org/${AUR_HELPER}.git
        
        if [ $? -eq 0 ]; then
            cd ${AUR_HELPER}
            echo -e "${BLUE}🔨 ${AUR_HELPER} derleniyor ve kuruluyor...${NC}"
            makepkg -si --noconfirm
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ ${AUR_HELPER} başarıyla kuruldu!${NC}"
            else
                echo -e "${RED}❌ ${AUR_HELPER} kurulumu başarısız!${NC}"
                cd ~
                rm -rf $TMP_DIR
                exit 1
            fi
        else
            echo -e "${RED}❌ ${AUR_HELPER} klonlanamadı!${NC}"
            cd ~
            rm -rf $TMP_DIR
            exit 1
        fi
        
        # Temizlik
        cd ~
        rm -rf $TMP_DIR
    else
        echo -e "${GREEN}✅ ${AUR_HELPER} zaten kurulu: $($AUR_HELPER --version 2>/dev/null || echo 'version ok')${NC}"
    fi
}

# 7. Proje dizini oluştur
create_project_dir() {
    echo -e "\n${BLUE}📁 6. Proje dizini oluşturuluyor...${NC}"
    
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    
    if [ "$SCRIPT_DIR" != "$HOME/aur-gui" ]; then
        echo -e "${YELLOW}⚠️  Proje ~/aur-gui dizinine kurulacak${NC}"
        mkdir -p ~/aur-gui
        # Mevcut dosyaları kopyala
        cp -r "$SCRIPT_DIR"/* ~/aur-gui/ 2>/dev/null
        cd ~/aur-gui
    fi
    
    echo -e "${GREEN}✅ Proje dizini: $(pwd)${NC}"
}

# 8. Config oluştur
create_config() {
    echo -e "\n${BLUE}⚙️  7. Yapılandırma oluşturuluyor...${NC}"
    
    CONFIG_DIR="$HOME/.config/aur-gui"
    CONFIG_FILE="$CONFIG_DIR/config.json"
    
    mkdir -p $CONFIG_DIR
    
    cat > $CONFIG_FILE << EOF
{
    "aur_helper": "$AUR_HELPER",
    "version": "1.0",
    "theme": "dark",
    "install_date": "$(date)"
}
EOF
    
    echo -e "${GREEN}✅ Yapılandırma oluşturuldu: $CONFIG_FILE${NC}"
}

# 9. Launcher script oluştur
create_launcher() {
    echo -e "\n${BLUE}🚀 8. Başlatıcı script oluşturuluyor...${NC}"
    
    cat > launcher.sh << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v python3 &> /dev/null; then
    zenity --error --text="Python 3 kurulu değil!\nLütfen installer.sh çalıştırın." 2>/dev/null
    exit 1
fi

python3 "$SCRIPT_DIR/aur_gui.py"
EOF
    
    chmod +x launcher.sh
    echo -e "${GREEN}✅ Başlatıcı oluşturuldu: launcher.sh${NC}"
}

# 10. Desktop dosyası oluştur
create_desktop_file() {
    echo -e "\n${BLUE}🖥️  9. Masaüstü kısayolu oluşturuluyor...${NC}"
    
    DESKTOP_FILE="$HOME/.local/share/applications/aur-manager.desktop"
    mkdir -p "$HOME/.local/share/applications/"
    
    SCRIPT_DIR="$(pwd)"
    
    cat > $DESKTOP_FILE << EOF
[Desktop Entry]
Name=AUR Manager
Comment=Modern Graphical AUR Package Manager
Exec=$SCRIPT_DIR/launcher.sh
Icon=system-software-install
Terminal=false
Type=Application
Categories=System;PackageManager;
StartupNotify=true
X-KDE-ModuleType=Application
EOF
    
    chmod +x $DESKTOP_FILE
    echo -e "${GREEN}✅ Masaüstü kısayolu oluşturuldu: $DESKTOP_FILE${NC}"
    
    # Desktop database'ini güncelle
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
}

# 11. Ana aur_gui.py dosyasının varlığını kontrol et
check_aur_gui() {
    echo -e "\n${BLUE}📄 10. Ana uygulama dosyası kontrol ediliyor...${NC}"
    
    if [ ! -f "aur_gui.py" ]; then
        echo -e "${RED}❌ aur_gui.py dosyası bulunamadı!${NC}"
        echo -e "${YELLOW}Lütfen aur_gui.py dosyasını bu dizine koyun: $(pwd)${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ aur_gui.py bulundu${NC}"
    fi
}

# 12. Kurulum özeti
show_summary() {
    echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ KURULUM TAMAMLANDI!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📦 Kurulanlar:${NC}"
    echo "   • base-devel (derleme araçları)"
    echo "   • git (versiyon kontrol)"
    echo "   • python3 $(python3 --version 2>/dev/null | cut -d' ' -f2)"
    echo "   • PyQt5 (GUI kütüphanesi)"
    echo "   • $AUR_HELPER (AUR helper)"
    echo ""
    echo -e "${BLUE}💾 Yapılandırma:${NC} ~/.config/aur-gui/config.json"
    echo -e "${BLUE}🚀 Başlatıcı:${NC} ~/.local/share/applications/aur-manager.desktop"
    echo -e "${BLUE}📁 Proje dizini:${NC} $(pwd)"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
}

# 13. Başlatma menüsü
start_menu() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎯 Ne yapmak istersiniz?${NC}"
    echo "1) Uygulamayı hemen başlat"
    echo "2) Sadece kurulum yap (başlatma)"
    echo "3) Çıkış"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    
    read -p "Seçiminiz (1-3): " menu_choice
    
    case $menu_choice in
        1)
            echo -e "${GREEN}🚀 Uygulama başlatılıyor...${NC}"
            python3 aur_gui.py
            ;;
        2)
            echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"
            echo -e "${YELLOW}Uygulamayı menüden 'AUR Manager' olarak başlatabilirsiniz.${NC}"
            ;;
        3)
            echo -e "${GREEN}Hoşçakalın! 🐧${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Geçersiz seçim!${NC}"
            start_menu
            ;;
    esac
}

# ANA KURULUM (TÜM FONKSİYONLAR ÇALIŞIR)
main() {
    check_base_devel
    check_git
    check_python
    check_pyqt5
    choose_aur_helper
    install_aur_helper
    create_project_dir
    create_config
    create_launcher
    create_desktop_file
    check_aur_gui
    show_summary
    start_menu
}

# Script'i çalıştır
main
