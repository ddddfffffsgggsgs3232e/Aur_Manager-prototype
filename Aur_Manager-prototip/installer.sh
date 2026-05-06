#!/bin/bash

# AUR Manager - Tam Otomatik Kurulum (aur_gui.py dahil)

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

# 1. base-devel
echo -e "\n${BLUE}🔧 base-devel kontrolü...${NC}"
if ! pacman -Q base-devel &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
fi

# 2. git
echo -e "\n${BLUE}🔧 git kontrolü...${NC}"
if ! command -v git &> /dev/null; then
    sudo pacman -S --needed --noconfirm git
fi

# 3. Python
echo -e "\n${BLUE}🔧 Python kontrolü...${NC}"
if ! command -v python3 &> /dev/null; then
    sudo pacman -S --needed --noconfirm python
fi

# 4. PyQt5
echo -e "\n${BLUE}🔧 PyQt5 kontrolü...${NC}"
if ! python3 -c "from PyQt5.QtWidgets import QApplication" &> /dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm python-pyqt5
fi

# 5. AUR helper seçimi
echo -e "\n${BLUE}════════════════════════════════════${NC}"
echo -e "${GREEN}AUR helper seçin:${NC}"
echo "1) paru (önerilen)"
echo "2) yay"
read -p "Seçim (1/2): " choice

if [ "$choice" = "1" ]; then
    AUR_HELPER="paru"
else
    AUR_HELPER="yay"
fi

# 6. AUR helper kur
echo -e "\n${BLUE}🔧 $AUR_HELPER kontrolü...${NC}"
if ! command -v $AUR_HELPER &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/$AUR_HELPER.git
    cd $AUR_HELPER
    makepkg -si --noconfirm
    cd ~
fi

# 7. Proje dizini oluştur
echo -e "\n${BLUE}📁 Proje dizini oluşturuluyor...${NC}"
mkdir -p ~/aur-gui
cd ~/aur-gui

# 8. aur_gui.py DOSYASINI OLUŞTUR (ÇOK ÖNEMLİ!)
echo -e "\n${BLUE}📄 aur_gui.py oluşturuluyor...${NC}"

cat > aur_gui.py << 'EOF'
#!/usr/bin/env python3
import sys
import json
import subprocess
from pathlib import Path
from PyQt5.QtWidgets import (QApplication, QMainWindow, QVBoxLayout, 
                             QWidget, QLineEdit, QPushButton, QTabWidget, 
                             QTextEdit, QMessageBox, QProgressBar, QLabel,
                             QGridLayout, QScrollArea, QFrame, QHBoxLayout)
from PyQt5.QtCore import QThread, pyqtSignal, Qt
from PyQt5.QtGui import QFont

CONFIG_PATH = Path.home() / ".config" / "aur-gui" / "config.json"

class PackageCard(QFrame):
    clicked = pyqtSignal(str)
    
    def __init__(self, package_name, description, parent=None):
        super().__init__(parent)
        self.package_name = package_name
        
        self.setFrameStyle(QFrame.Box)
        self.setCursor(Qt.PointingHandCursor)
        self.setMaximumHeight(100)
        self.setMinimumWidth(250)
        self.setStyleSheet("""
            QFrame {
                background-color: #2a2e33;
                border-radius: 8px;
                border: 1px solid #3d4451;
                margin: 5px;
            }
            QFrame:hover {
                background-color: #31363d;
                border: 1px solid #5294e2;
            }
        """)
        
        layout = QVBoxLayout()
        self.setLayout(layout)
        
        name_label = QLabel(f"📦 {package_name}")
        name_label.setStyleSheet("font-weight: bold; font-size: 14px; color: #5294e2;")
        layout.addWidget(name_label)
        
        desc_label = QLabel(description[:80] + ("..." if len(description) > 80 else ""))
        desc_label.setStyleSheet("color: #d0d4dc; font-size: 11px;")
        desc_label.setWordWrap(True)
        layout.addWidget(desc_label)
        
        install_btn = QPushButton("📥 Kur")
        install_btn.setStyleSheet("""
            QPushButton {
                background-color: #3daee9;
                border: none;
                border-radius: 5px;
                padding: 5px;
                color: white;
                font-weight: bold;
            }
        """)
        install_btn.clicked.connect(lambda: self.clicked.emit(self.package_name))
        layout.addWidget(install_btn)
    
    def mousePressEvent(self, event):
        self.clicked.emit(self.package_name)

class SearchThread(QThread):
    result_ready = pyqtSignal(list)
    finished = pyqtSignal()
    
    def __init__(self, helper, query):
        super().__init__()
        self.helper = helper
        self.query = query
    
    def run(self):
        try:
            cmd = [self.helper, "-Ss", self.query]
            result = subprocess.run(cmd, capture_output=True, text=True)
            packages = []
            lines = result.stdout.split('\n')
            
            i = 0
            while i < len(lines):
                if lines[i] and not lines[i].startswith(' '):
                    pkg_name = lines[i].split()[0]
                    pkg_desc = ""
                    if i + 1 < len(lines) and lines[i+1].startswith('    '):
                        pkg_desc = lines[i+1].strip()
                    packages.append((pkg_name, pkg_desc))
                    i += 2
                else:
                    i += 1
            
            self.result_ready.emit(packages[:30])
        except Exception as e:
            self.result_ready.emit([(f"Hata: {str(e)}", "")])
        self.finished.emit()

class InstallThread(QThread):
    finished = pyqtSignal(bool, str)
    
    def __init__(self, helper, package):
        super().__init__()
        self.helper = helper
        self.package = package
    
    def run(self):
        try:
            cmd = [self.helper, "-S", "--noconfirm", self.package]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            output = ""
            for line in process.stdout:
                output += line
            process.wait()
            if process.returncode == 0:
                self.finished.emit(True, f"✅ {self.package} kuruldu!")
            else:
                self.finished.emit(False, f"❌ {self.package} kurulamadı!")
        except Exception as e:
            self.finished.emit(False, f"❌ Hata: {str(e)}")

class AURManager(QMainWindow):
    def __init__(self):
        super().__init__()
        self.load_config()
        self.init_ui()
        
    def load_config(self):
        try:
            with open(CONFIG_PATH, "r") as f:
                config = json.load(f)
                self.aur_helper = config.get("aur_helper", "paru")
        except:
            self.aur_helper = "paru"
    
    def init_ui(self):
        self.setWindowTitle(f"AUR Manager - {self.aur_helper}")
        self.setGeometry(100, 100, 1000, 700)
        
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        main_layout = QVBoxLayout()
        central_widget.setLayout(main_layout)
        
        tabs = QTabWidget()
        main_layout.addWidget(tabs)
        
        # Arama sekmesi
        search_tab = QWidget()
        tabs.addTab(search_tab, "🔍 Paket Ara")
        
        search_layout = QVBoxLayout()
        search_tab.setLayout(search_layout)
        
        # Arama kutusu
        search_frame = QHBoxLayout()
        self.search_box = QLineEdit()
        self.search_box.setPlaceholderText("Paket adı girin...")
        self.search_box.returnPressed.connect(self.search_packages)
        search_frame.addWidget(self.search_box)
        
        self.search_button = QPushButton("🔍 Ara")
        self.search_button.clicked.connect(self.search_packages)
        search_frame.addWidget(self.search_button)
        search_layout.addLayout(search_frame)
        
        # Progress bar
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        search_layout.addWidget(self.progress_bar)
        
        # Scroll alanı
        self.scroll_area = QScrollArea()
        self.scroll_area.setWidgetResizable(True)
        self.grid_widget = QWidget()
        self.grid_layout = QGridLayout(self.grid_widget)
        self.scroll_area.setWidget(self.grid_widget)
        search_layout.addWidget(self.scroll_area)
        
        # Kurulum sekmesi
        install_tab = QWidget()
        tabs.addTab(install_tab, "📦 Kurulum Çıktısı")
        
        install_layout = QVBoxLayout()
        install_tab.setLayout(install_layout)
        
        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        install_layout.addWidget(self.output_text)
        
        # Durum çubuğu
        self.status_label = QLabel(f"Hazır - AUR Helper: {self.aur_helper}")
        main_layout.addWidget(self.status_label)
        
        self.search_thread = None
    
    def clear_grid(self):
        for i in reversed(range(self.grid_layout.count())):
            widget = self.grid_layout.itemAt(i).widget()
            if widget:
                widget.deleteLater()
    
    def search_packages(self):
        query = self.search_box.text().strip()
        if not query:
            return
        
        self.clear_grid()
        self.progress_bar.setVisible(True)
        self.progress_bar.setRange(0, 0)
        self.search_button.setEnabled(False)
        self.status_label.setText(f"Aranıyor: {query}...")
        
        self.search_thread = SearchThread(self.aur_helper, query)
        self.search_thread.result_ready.connect(self.display_results)
        self.search_thread.finished.connect(self.search_finished)
        self.search_thread.start()
    
    def display_results(self, packages):
        self.clear_grid()
        
        if not packages:
            label = QLabel("Sonuç bulunamadı.")
            label.setAlignment(Qt.AlignCenter)
            self.grid_layout.addWidget(label, 0, 0)
            return
        
        row, col = 0, 0
        for pkg_name, pkg_desc in packages:
            card = PackageCard(pkg_name, pkg_desc or "Açıklama yok")
            card.clicked.connect(self.install_package)
            self.grid_layout.addWidget(card, row, col)
            col += 1
            if col >= 3:
                col = 0
                row += 1
    
    def search_finished(self):
        self.progress_bar.setVisible(False)
        self.search_button.setEnabled(True)
        self.status_label.setText(f"✅ {self.grid_layout.count()} sonuç bulundu")
    
    def install_package(self, package_name):
        reply = QMessageBox.question(self, "Onay", f"{package_name} kurulsun mu?",
                                    QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            self.output_text.clear()
            self.status_label.setText(f"Kuruluyor: {package_name}...")
            
            self.install_thread = InstallThread(self.aur_helper, package_name)
            self.install_thread.finished.connect(self.install_finished)
            self.install_thread.start()
    
    def install_finished(self, success, message):
        self.status_label.setText(message)
        self.output_text.append(message)
        QMessageBox.information(self, "Sonuç", message)

def main():
    app = QApplication(sys.argv)
    window = AURManager()
    window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
EOF

# 9. Config oluştur
echo -e "\n${BLUE}⚙️ Config oluşturuluyor...${NC}"
mkdir -p ~/.config/aur-gui
cat > ~/.config/aur-gui/config.json << EOF
{
    "aur_helper": "$AUR_HELPER"
}
EOF

# 10. Launcher oluştur
echo -e "\n${BLUE}🚀 Launcher oluşturuluyor...${NC}"
cat > launcher.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
python3 aur_gui.py
EOF
chmod +x launcher.sh

# 11. Desktop dosyası
echo -e "\n${BLUE}🖥️ Desktop kısayolu oluşturuluyor...${NC}"
mkdir -p ~/.local/share/applications/
cat > ~/.local/share/applications/aur-manager.desktop << EOF
[Desktop Entry]
Name=AUR Manager
Exec=$HOME/aur-gui/launcher.sh
Icon=system-software-install
Terminal=false
Type=Application
Categories=System;
EOF

# 12. Özet
echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ KURULUM TAMAMLANDI!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📦 AUR Helper: $AUR_HELPER${NC}"
echo -e "${BLUE}📁 Dizin: ~/aur-gui${NC}"
echo -e "${BLUE}🚀 Başlat: python3 ~/aur-gui/aur_gui.py${NC}"
echo -e "${BLUE}🖥️ Menü: AUR Manager${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"

# 13. Başlatma seçeneği
echo ""
read -p "Uygulamayı şimdi başlatmak ister misiniz? (e/H): " start
if [[ "$start" == "e" || "$start" == "E" ]]; then
    python3 aur_gui.py
fi
