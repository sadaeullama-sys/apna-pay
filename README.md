# APNA PAY Demo v1.0

Flutter Android demo prototype.

## Included
- Demo account registration and demo login
- KYC process preview (CNIC front/back and selfie placeholders)
- KYC status display
- Wallet dashboard with sample balance
- Demo send money, mobile load, bill payment and add-money interactions
- Transaction history and profile
- GitHub Actions workflow for building a release APK

## Build
Install Flutter 3.24.5 or compatible stable Flutter, then run:
```bash
flutter pub get
flutter run
flutter build apk --release
```
Or push to GitHub and run **Build APNA PAY Demo APK** from Actions.

## Important limitations
This is a demonstration only. The sample balance and transactions are not real funds. KYC upload buttons are placeholders; no CNIC images are collected or stored. There is no NADRA, biometric, liveness, OTP, bank, EMI, Raast, mobile operator or biller integration. Do not enter real CNIC, OTP, banking PIN or payment details.

A real wallet requires a licensed/authorized financial institution or EMI partner, approved API access, secure backend ledger, KYC/AML controls, privacy and security review, monitoring, reconciliation and legal approval.
