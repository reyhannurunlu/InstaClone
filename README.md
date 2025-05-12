# 📸 InstaClone

Swift 5.9 ile geliştirilen, **Firebase** tabanlı gerçek zamanlı Instagram klonu.  
Gönderi paylaş, beğen, sil – hepsi bulutta ve anlık! 🚀

<div align="center">
  <img src="Docs/demo_feed.gif" width="260"> <img src="Docs/demo_upload.gif" width="260">
</div>

---

## Özellikler

| 🚀 | Açıklama |
|----|----------|
| **Gerçek Zamanlı Feed** | Firestore `SnapshotListener` ile otomatik yenilenen gönderi listesi |
| **Beğeni Transaction’ı** | ACID garantili `runTransaction` – çifte tıklamada bile tutarlı sayaç |
| **Medya Yükleme** | JPEG sıkıştırma + Storage URL’si alma + Firestore meta kaydı |
| **Yetkili Silme** | Gönderi sahipliği kontrolü -> Güvenli doküman & dosya silme |
| **Optimistik UI** | Ağ gecikmesinde bile anında görsel geri bildirim |
| **Kingfisher Cache** | Görseller için disk+bellek önbelleği |

---

## Teknolojiler

- **Swift 5.9**, UIKit
- **Firebase**: Auth · Firestore · Storage
- **Package Manager**: SwiftPM
- **Kingfisher** (görsel önbellekleme)

---

## Kurulum

> **Ön koşul**: Xcode 15+, CocoaPods veya SwiftPM, Firebase projesi

```bash
git clone https://github.com/kullaniciadi/InstaClone.git
cd InstaClone
open InstaClone.xcodeproj
