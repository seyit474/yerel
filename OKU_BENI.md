# Yerel Messenger

Aynı Wi-Fi'daki cihazlar için Telegram benzeri mesajlaşma. Sunucu telefonda (Termux) çalışır, internet gerekmez, hiçbir şey dışarı gitmez.

- Metin, fotoğraf, video, **sınırsız boyutta dosya** (Gmail sınırı yok)
- **Kayıtlı Mesajlar**: telefon ↔ bilgisayar arası dosya/metin taşıma
- Özel sohbet ve gruplar, yanıtla, ilet, düzenle, sil, okundu tikleri, "yazıyor…"
- Sesli mesaj, **sesli ve görüntülü arama** (1-1, WebRTC)
- Android "Paylaş → Yerel", bilgisayarda sürükle-bırak ve Ctrl+V
- Chrome'da **ana ekrana eklenebilir** (PWA), açık/koyu tema
- Bağımlılık yok: sadece Node.js

## Kurulum (Termux)

```bash
cd ~ && unzip -o /sdcard/Download/yerel_messenger.zip && cd yerel && bash kurulum.sh && bash baslat.sh
```

Sonraki seferlerde sadece: `cd ~/yerel && bash baslat.sh`

Ekranda çıkan adresi (ör. `https://192.168.1.5:8443`) diğer cihazlarda aç, hesap oluştur.

## Güvenli bağlantı (bir kez, her cihazda)

Mikrofon, kamera, bildirim ve ana ekrana ekleme yalnızca **https** üzerinde çalışır. `kurulum.sh` yerel bir sertifika otoritesi (CA) üretir; bunu cihazlara bir kez kurman yeterli:

1. Uygulamada **Ayarlar → Sertifika kurulumu → Sertifikayı indir** (ya da `http://IP:8080/ca.crt`)
2. **Android:** Ayarlar → Güvenlik → Şifreleme ve kimlik bilgileri → Sertifika yükle → **CA sertifikası**
   **Windows:** dosyaya çift tıkla → Sertifika yükle → Yerel Makine → **Güvenilen Kök Sertifika Yetkilileri**
3. Chrome'u yeniden başlat, `https://IP:8443` adresini aç.

IP değişirse sunucu sertifikayı aynı CA ile kendisi yeniler, tekrar kurulum gerekmez.

Hızlı alternatif: `chrome://flags/#unsafely-treat-insecure-origin-as-secure` → `http://IP:8080` yaz → Enabled → Relaunch.

## Ayarlar

| Değişken | Varsayılan | Açıklama |
|---|---|---|
| `PORT` | 8080 | HTTP portu |
| `HTTPS_PORT` | 8443 | HTTPS portu |
| `DAVET_KODU` | – | Ayarlanırsa kayıt için bu kod istenir |
| `LAN_IP` | otomatik | IP bulunamazsa elle ver (virgülle) |
| `EKSTRA_IP` | – | `sertifika.sh` için ek IP |

Örnek: `DAVET_KODU=ev123 bash baslat.sh`

Sertifika: `bash sertifika.sh --yenile` (sunucu sertifikası), `bash sertifika.sh --sifirla` (CA dahil; cihazlara tekrar kurulur).

## Bilinmesi gerekenler

- Veriler `data/` klasöründe (mesajlar JSON, dosyalar `data/files/`). Yedek için bu klasörü kopyala.
- Telefon uyursa sunucu durabilir: `baslat.sh` wake-lock alır; ayrıca Termux için pil optimizasyonunu kapat.
- Bildirimler, uygulama arka planda açıkken gelir (internet push servisi yok).
- Aramalar 1-1'dir ve aynı ağda çalışır. Bazı router'larda "AP/Client Isolation" açıksa cihazlar birbirini göremez; kapat.
- Hotspot: sunucu telefonu hotspot açarsa diğer cihazlar ona bağlanıp kullanabilir.

## Android uygulaması (APK)
`android/` klasörü, sunucuya bağlanan bir istemci uygulamasıdır (sunucu yine Termux'ta çalışır). APK GitHub Actions ile derlenir:
```bash
pkg install -y git gh && gh auth login && cd ~/yerel && git init -b main && git add -A && git commit -m yerel && gh repo create yerel --private --source=. --push
```
Birkaç dakika sonra APK: GitHub → repo → **Releases** (veya Actions → son çalıştırma → *Yerel-apk*).

Uygulama ilk açılışta ağdaki sunucuyu otomatik bulur. Web sürümüne göre farkları:
- Arka planda açık kalır (bildirim çubuğunda "Yerel bağlı"), mesaj bildirimleri ve gelen aramada zil + tam ekran arama ekranı.
- Herhangi bir uygulamadan **Paylaş → Yerel**.
- İndirilen dosyalar **İndirilenler/Yerel** klasörüne gider.
- Ayarlar → **Sunucuyu değiştir**.
