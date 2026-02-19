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

## 🤖 AI Agent Setup & VM Installation Guide

This section is optimized for AI agents setting up the project in a virtual environment.

### 🛠 Environment Requirements
- **Flutter SDK:** `3.38.3` (Stable Channel)
- **Dart SDK:** `3.10.1`
- **Java JDK:** `OpenJDK 17`
- **Android SDK:** API Level 33+ (Android 13)
- **CocoaPods:** (For iOS only) `1.12.0+`

### � Test Credentials
For quick evaluation, you can use the following test account:
- **Email:** `omersaidakcin@gmail.com`
- **Password:** `123123`

### �🚀 Direct Setup Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/wertyu1344/doktorapp.git
   cd doktorapp
   ```

2. **Clean and Fetch Dependencies:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Verify Firebase Configuration:**
   - The project is **pre-configured** with Firebase.
   - Essential files already included in the repo:
     - `lib/firebase_options.dart` (Universal configuration)
     - `android/app/google-services.json` (Android specific)
   - *Note:* Authentication (Email/Password), Firestore, and Storage must be enabled in the Firebase Console for the linked project.

4. **Run the Application:**
   ```bash
   # For Android Emulator/Device
   flutter run
   ```

### 📱 Build & APK Location
If you need to access the ready-to-use production build:

- **Build Command:**
  ```bash
  flutter build apk --release
  ```
- **Release APK Path:** 
  `build/app/outputs/flutter-apk/app-release.apk`
  
*(This APK contains all recent fixes including evaluation navigation and photo swipe optimizations.)*

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
│       ├── general_evaluation_screen.dart # Genel değerlendirme
│       └── evaluation_detail_screen.dart  # Muayene detay (YENİ)
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
