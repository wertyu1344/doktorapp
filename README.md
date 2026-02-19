# 🦷 DoktorApp — Dental Klinik Yönetim Sistemi

Diş hekimleri için geliştirilen, hasta kayıtları, ağız içi fotoğraf yönetimi ve dental değerlendirme yapabilen mobil uygulama.

## 📱 Ekran Görüntüleri

| Giriş | Ana Sayfa | Hasta Detay |
|-------|-----------|-------------|
| Login & Register | Hasta Listesi | Bilgi & Fotoğraflar |

| Dental Değerlendirme | Genel Değerlendirme | Fotoğraf Yönetimi |
|----------------------|--------------------|--------------------|
| Diş seçimi & bulgular | Diş eti & periodontal | Kamera & galeri |

## ✨ Özellikler

- 🔐 **Firebase Authentication** — Email/şifre ile güvenli giriş
- 📋 **Hasta Yönetimi** — Ekleme, düzenleme, silme, arama
- 📸 **Fotoğraf Yönetimi** — Kamera veya galeriden fotoğraf ekleme (Firebase Storage)
- 🦷 **Dental Değerlendirme** — Kalıcı ve süt dişleri seçimi, diş bazlı bulgu ekleme
- 📊 **Genel Değerlendirme** — Diş eti muayenesi, periodontal muayene
- 📝 **Anamnez** — Hasta tıbbi geçmiş bilgileri
- 🔍 **Arama & Filtreleme** — İsim, hasta no veya bölgeye göre arama
- 🎨 **Modern UI** — Kırmızı-beyaz renk paleti, animasyonlar, responsive tasarım
- ⚠️ **Hata Yönetimi** — Loading, empty state, error handling

## 🛠 Kullanılan Teknolojiler

- **Flutter** (Dart)
- **Firebase Core**
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **Image Picker**
- **Cached Network Image**
- **Google Fonts (Poppins)**
- **intl** (Tarih formatlama)
- **uuid** (Benzersiz ID üretimi)

## 📦 Kurulum & Çalıştırma

### Gereksinimler
- Flutter SDK (3.10+)
- Firebase projesi
- Android Studio veya VS Code

### Adımlar

1. **Repoyu klonlayın:**
```bash
git clone https://github.com/KULLANICI_ADI/doktorapp.git
cd doktorapp
```

2. **Firebase CLI kurulumu:**
```bash
dart pub global activate flutterfire_cli
```

3. **Firebase yapılandırması:**
```bash
flutterfire configure
```
Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturacak.

4. **`google-services.json`** dosyasını `android/app/` klasörüne koyun.

5. **Firebase Console'da aktif edin:**
   - Authentication → Email/Password
   - Firestore Database
   - Storage

6. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

7. **Uygulamayı çalıştırın:**
```bash
flutter run
```

### APK Build

```bash
flutter build apk --release
```

## 📂 Proje Yapısı

```
lib/
├── main.dart                        # Ana giriş noktası + tema
├── firebase_options.dart            # Firebase yapılandırması
├── models/
│   ├── patient.dart                 # Hasta modeli
│   └── dental_evaluation.dart       # Dental değerlendirme modeli
├── services/
│   ├── auth_service.dart            # Firebase Auth servisi
│   ├── firestore_service.dart       # Firestore CRUD işlemleri
│   └── storage_service.dart         # Firebase Storage servisi
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        # Giriş ekranı
│   │   └── register_screen.dart     # Kayıt ekranı
│   ├── home/
│   │   └── home_screen.dart         # Ana sayfa (hasta listesi)
│   ├── patient/
│   │   ├── add_patient_screen.dart  # Hasta ekleme
│   │   └── patient_detail_screen.dart # Hasta detay
│   └── evaluation/
│       ├── dental_evaluation_screen.dart  # Dental değerlendirme
│       └── general_evaluation_screen.dart # Genel değerlendirme
└── widgets/
    └── patient_card.dart            # Hasta kart widget'ı
```

## 🎯 Hedef Kullanıcı Kitlesi

- Diş hekimleri
- Dental klinik personeli
- Ağız ve diş sağlığı alanında çalışan sağlık profesyonelleri

## 💡 Çözmek İstediğimiz Problem

Diş hekimleri genellikle hasta kayıtlarını kağıt üzerinde veya dağınık dijital araçlarla tutar. DoktorApp, hasta yönetimini tek bir mobil uygulamada birleştirerek:
- Ağız içi fotoğraflarını organize eder
- Diş bazlı bulgu takibi sağlar
- Anamnez bilgilerini dijitalleştirir
- Hızlı ve erişilebilir bir muayene kaydı sunar

## 🎨 Pinterest Panosundan Alınan İlhamlar

- **Kırmızı-beyaz renk paleti** — Tıbbi profesyonellik hissi
- **Kart tabanlı bilgi düzeni** — Hasta bilgileri ve anamnez ayrı kartlarda
- **Fotoğraf karüsel** — Ağız içi fotoğrafları ok butonlarıyla gezinme
- **Diş numarası grid** — FDI numaralama sistemiyle interaktif diş seçimi
- **Chip bazlı bulgu seçimi** — Hızlı ve dokunmatik dostu arayüz

## 📄 Lisans

Bu proje eğitim amaçlı oluşturulmuştur.
