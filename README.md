# CAMMOT

> **Camera Remote Control** — Gunakan kamera perangkat A secara real-time dari perangkat B melalui browser.

## 🎯 Fitur

### Perangkat A (Broadcaster)
- 🎥 **Broadcast kamera** — Streaming kamera depan/belakang secara live
- 🔄 **Ganti kamera** — Switch antara kamera depan dan belakang
- 🔦 **Flashlight/Torch** — Nyalakan/matikan saku (Android)
- 📸 **Ambil foto** — Snapshot dari stream lokal
- 🔊 **Toggle audio** — Aktifkan/matikan microphone

### Perangkat B (Viewer)
- 👁️ **Live view** — Tonton stream kamera remote secara real-time
- ⏺️ **Rekam video** — Rekam stream remote ke file `.webm`
- 📸 **Ambil foto** — Snapshot dari stream remote
- 🖥️ **Fullscreen** — Mode layar penuh

## 🛠️ Teknologi

| Layer | Teknologi |
|---|---|
| Backend | Node.js, Express 5 |
| Signaling | Socket.IO (WebSocket) |
| Media | WebRTC (P2P) |
| STUN/TURN | Google STUN + OpenRelay TURN |
| Frontend | Vanilla HTML/CSS/JS |

## 📦 Instalasi

```bash
git clone https://github.com/t0536844-sketch/cammot.git
cd cammot
npm install
```

## 🚀 Cara Pakai

### 1. Jalankan server
```bash
npm start
```
Server berjalan di `http://localhost:3000`

### 2. Perangkat A (Broadcaster)
- Buka `http://<IP-LAN-kamu>:3000` di browser HP/laptop
- Klik **"Mulai Broadcast Kamera"**
- Izinkan akses kamera (dan audio jika diperlukan)

### 3. Perangkat B (Viewer)
- Buka URL yang sama di perangkat lain (harus satu jaringan LAN)
- Klik **"Lihat Kamera Remote"**
- Stream akan muncul setelah koneksi WebRTC terbentuk

> 💡 **Tips:** Gunakan IP LAN (contoh: `192.168.1.100:3000`) agar perangkat lain bisa mengakses. Jangan gunakan `localhost` untuk akses dari perangkat lain.

## 🏗️ Arsitektur

```
┌──────────────┐     Socket.IO      ┌──────────┐     Socket.IO      ┌──────────────┐
│  Perangkat A  │ ◄── signaling ───► │  Server  │ ◄── signaling ───► │  Perangkat B  │
│ (Broadcaster) │                    │(Express+ │                    │   (Viewer)     │
│              │ ◄──── WebRTC P2P ──────────────────────► │              │
│   Kamera 📷  │      (media)       │ Socket)  │      (media)       │   Layar 🖥️   │
└──────────────┘                    └──────────┘                    └──────────────┘
```

- **Signaling** melalui Socket.IO (server bertindak sebagai perantara)
- **Media stream** langsung P2P via WebRTC (tidak melewati server)
- Hanya **1 broadcaster** aktif dalam satu waktu
- **Banyak viewer** bisa terhubung ke 1 broadcaster

## 🌐 Akses dari Jaringan Lain

Untuk akses dari luar LAN, pastikan:
1. Firewall mengizinkan port `3000`
2. Atur port forwarding di router (jika diperlukan)
3. TURN server sudah dikonfigurasi (default: `openrelay.metered.ca`)

## 📝 License

ISC
