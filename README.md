# OSIRIS PASS

> **DECENTRALIZED MULTI-VAULT PASSWORD KEEPER**
> Completely localized, secure, and cross-platform mobile ecosystem tailored for Android & iOS. Built in an authentic cyberpunk/terminal style.

---

## About The Project

OSIRIS PASS is a fully decentralized, autonomous password manager featuring a native light-blue neon interface. Unlike classic cloud-based solutions, this application isolates your data within the operating system and never transmits confidential information to external servers.

The interface is engineered specifically for mobile screens. The record-creation forms and the encrypted credential index are separated into independent, streamlined tabs managed via a Bottom Navigation Bar. This layout completely eliminates text overflows, text clipping, and overlapping elements on mobile devices.

---

## Cryptographic Engine (Crypto Engine)

To deliver maximum performance on mobile devices and ensure an instant UI response without freezing execution threads, the application utilizes an optimized, secure cryptographic scheme:

1. **Key Derivation:** A high-speed SHA-256 hash is computed from your Master Password and a unique 16-byte cryptographic salt generated individually for each account. This mechanism thwarts dictionary attacks and ensures the uniqueness of the encryption key.
2. **Symmetric Encryption:** The vault data is serialized into JSON format and securely encrypted using the AES-GCM (256-bit) algorithm.
3. **Integrity Control:** The GCM mode automatically calculates an authentication tag (MAC). If an incorrect Master Password is provided, the algorithm safely aborts decryption and blocks system entry rather than returning corrupted data.
4. **Isolated Storage (Android Keystore):** The encrypted data block and salts are never stored in plain text on the device storage. They are written directly to the secure internal storage of the OS via the `flutter_secure_storage` package, which leverages hardware-backed encryption (Android Keystore / iOS Keychain).

---

## Mobile Concept Features

- **Two-Page Layout:** Logical separation of views into distinct '[ ADD VAULT ]' and '[ SECURED INDEX ]' tabs.
- **Password Generator:** Instant creation of cryptographically strong random passwords and 26-digit Digital Accounts IDs directly within the application terminal.
- **Mobile Usability:** Large, touch-friendly input fields and action buttons: '[ SHOW ]', '[ COPY KEY ]', and '[ DELETE ]'.
- **Leak Protection:** Hidden password fields with toggle controls and one-click data copying to the system clipboard.
- **Terminal Lock:** A manual '[ LOCK ]' trigger to immediately close the vault and wipe decrypted strings from the device memory.

---

## Getting Started & Compilation

### 1. Prerequisites
- Installed **Flutter SDK**
- Configured **Android SDK** (for Android builds)

### 2. Dependency Resolution
Ensure all required native plugins are properly resolved in your workspace:
```bash
flutter pub get
```

### 3. Launcher Icon Generation
The application utilizes a custom light-blue neon eye-key launcher icon. To slice and deploy it into all native Android asset directories, execute:
```bash
dart run flutter_launcher_icons
```

### 4. Compiling the Release APK
To compile a fully optimized, production-ready application bundle, run:
```bash
flutter clean && flutter pub get && flutter build apk --release
```
The compiled installation package will be generated at: `build/app/outputs/flutter-apk/app-release.apk`.

---

## Technical Stack

- **Framework:** Flutter (Dart)
- **Cryptography:** PointyCastle (AES-GCM-256, SHA-256)
- **Secure Storage:** Flutter Secure Storage (Android Keystore / iOS Keychain)
- **Styling:** Custom Cyberpunk/Neon Digital Theme

---
*Powered by @xrlmop | Osiris Pass Ecosystem*
