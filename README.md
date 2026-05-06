# Aur_Manager-prototype
Aur helper.
🅰️ AUR Manager

Arch Linux için basit AUR grafik arayüzü
🚀 Özellikler

    🔍 AUR'da paket ara

    📥 Paket kur (tek tık)

    🎨 Modern kart görünümü

    ⚡ Otomatik bağımlılık kurulumu (Python, PyQt5, paru/yay)

    🖥️ Masaüstü entegrasyonu

📦 Kurulum
bash

git clone https://github.com/ddddfffffsgggsgs3232e/Aur_Manager-prototype
cd Aur-Manager-prototype
chmod +x installer.sh
./installer.sh

    Script Python, PyQt5, base-devel, git, paru/yay eksikse OTOMATİK KURAR!

🎯 Kullanım
Ne yapmak istiyorsun?	Nasıl?
Paket ara	"🔍 Paket Ara" sekmesine yaz → Ara
Paket kur	Karttaki "📥 Kur" butonuna tıkla
Kurulum çıktısını gör	"📦 Kurulum Çıktısı" sekmesi
📂 Dosyalar
text

aur-manager/
├── aur_gui.py          # Ana uygulama
├── installer.sh        # Otomatik kurulum
├── launcher.sh         # Başlatıcı
└── complete_uninstall.sh # Tam kaldırma
// ayrıca otomatik olarak .desktop dosyası oluşturuyor.
🗑️ Kaldırma
bash

./complete_uninstall.sh

❌ Şu anda YOK (gelecek sürümde)

    ~~Toplu paket kurulumu~~

    ~~Kurulu paket listeleme~~

    ~~Paket kaldırma~~

    ~~Güncelleme kontrolü~~

    ~~Açık/Koyu tema~~

📝 Not

Bu uygulama sadece arama ve kurma yapar.
Kurulu paketleri görmek, kaldırmak veya güncellemek için terminalde paru -Qm veya yay -Qm kullanın.

Basit, hızlı, işini yapan bir AUR GUI 🐧

Bu gerçek kodlarla %100 uyumlu. Sadece arama ve kurma var. Diğer özellikler yok. Dürüst ve sade 👍
