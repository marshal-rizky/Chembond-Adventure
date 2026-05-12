# ChemBond Adventure — Spesifikasi Redraw Asset

## Tema & Palette

**Nuansa:** Lab kimia bawah tanah rahasia / pelarian dari lab rumah sakit. Estetika System Shock + Alien. Dinding navy gelap, lantai grid teal, aksen hazard.

**Gaya:** Pixel art 2D top-down. Grain 16 piksel (1 tile maze = 16×16 px, ditampilkan pada 3× = 48 px di layar). Tepi keras, tanpa anti-aliasing, tanpa brush lembut. `texture_filter = NEAREST` di mana-mana.

**Palette (terkunci — cocokkan dengan tileset dan UI theme yang ada):**

| Peran | Hex | Penggunaan |
|---|---|---|
| Wall deep | `#050612` | Bayangan / outline dinding |
| Wall mid | `#0d1626` | Badan dinding |
| Wall hi | `#1d3554` | Highlight dinding |
| Floor base | `#143747` | Badan lantai |
| Floor grid | `#1e5069` | Garis grid tepi tile lantai |
| Terminal teal | `#14b8a6` | Border UI / LED perangkat / aksen |
| Terminal teal hi | `#5eead4` | Glow / highlight hover |
| Terminal text | `#cfeae6` | Teks UI di latar gelap |
| Hazard red | `#ef4444` | Terkunci / peringatan |
| Hazard amber | `#f59e0b` | Garis-garis kaution (opsional) |
| Bg deep | `#070b14` | Bayangan dalam panel UI |

**Arah pencahayaan:** Sumber cahaya dari kiri atas. Highlight di tepi atas + kiri, bayangan di tepi bawah + kanan.

---

## Di Luar Lingkup (sudah selesai — JANGAN digambar ulang)

- `assets/tiles_wang.png` — tileset maze (baru saja dibangun ulang)
- Titik LED indikator gate (programatik, bukan sprite)

---

## Asset yang Perlu Digambar Ulang

### 1. `assets/sprites/player.png` — 16×16 RGBA
Sprite player statis tunggal. **Kemungkinan sudah usang** — game menggunakan animation frames ilmuwan. Konfirmasi dengan dev apakah perlu dihapus atau diperbarui. Jika dipertahankan: ahli kimia top-down berjas lab, 16×16, menghadap selatan.

### 2. `assets/sprites/element.png` — 32×32 RGBA
Sprite dasar pickup atom/molekul generik. Diwarnai saat runtime per elemen (H=cyan, O=red, C=gray, Na=yellow, Cl=green, N=blue, Mg=orange, Ca=orangered, Si=brown, S=yellowgreen, K=purple, Fe=darkgray, Cu=coral, Zn=slategray).
- **Desain:** ikon atom sederhana — lingkaran nukleus di tengah + 1-2 cincin orbital. Mayoritas putih/abu-abu agar modulate saat runtime menghasilkan tint yang bersih. Tanpa warna baked.
- **Padding:** beri border transparan 2-3 px, seni sprite muat sekitar 26×26 di dalamnya.
- **Keterbacaan:** harus terbaca pada skala 3× (96×96 akhir). Teks simbol elemen ditambahkan terpisah oleh kode game; jangan baked huruf ke dalam sprite.

### 3. `assets/sprites/gate_locked.png` — 32×32 RGBA
Pintu keamanan lab yang tersegel, tampilan top-down.
- Pintu bulkhead berat dengan plat segel magnetik, terbenam ke dalam dinding.
- Warna: bulkhead navy gelap `#0d1626`, seam trim teal di tengah `#14b8a6`.
- **Tanpa LED baked** — runtime menambahkan titik LED merah di atas pintu.
- **Tanpa teks/label baked.**
- Shadow gutter 1-2 px agar pintu terlihat tertanam di dinding.

### 4. `assets/sprites/gate_open.png` — 32×32 RGBA
Pintu yang sama, teretraksi/terbuka.
- Terlihat tepi doorframe kiri + kanan; bagian tengah memperlihatkan lantai koridor yang memanjang.
- Palette + dimensi sama dengan `gate_locked.png`.
- **Tanpa LED baked** (LED hijau ditambahkan saat runtime).
- Lantai di tengah mengikuti palette tile lantai agar terlihat menyambung.

### 5. `assets/sprites/joystick_base.png` — 64×64 RGBA
Cincin luar virtual joystick (input touch).
- Cincin teal tipis 2-3 px, isi navy semi-transparan (~50% alpha).
- Tanda crosshair di tengah (4 tick pendek di N/E/S/W) berwarna teal.
- Estetika terminal HUD — terlihat seperti reticle penargetan, bukan cincin gamepad generik.

### 6. `assets/sprites/joystick_handle.png` — 32×32 RGBA
Thumb yang bisa didrag ke dalam.
- Disc teal terisi dengan ring highlight dalam 1 px yang lebih terang.
- Titik tengah untuk feel genggaman.
- ~80% alpha agar pemain bisa melihat lantai di bawahnya.

### 7. `assets/sprites/scientist/` — 48×48 RGBA (animation frames)
Karakter player. **Total 76 frame** untuk 4 arah × beberapa aksi.

**Struktur direktori (pertahankan persis seperti ini):**
```
scientist/
├── rotations/
│   ├── north.png  east.png  south.png  west.png        (4 statis)
└── animations/
    ├── idle/{north,east,south,west}/frame_000..003.png (16 frames)
    ├── walk/{north,east,south,west}/frame_000..003.png (16 frames)
    ├── run/ {north,east,south,west}/frame_000..003.png (16 frames)
    └── collect/{north,east,south,west}/frame_000..004.png (20 frames)
```

**Desain karakter:**
- Perspektif 3/4 top-down ilmuwan berjas lab putih, kacamata gelap atau kacamata biasa, sarung tangan.
- Frame 48×48; karakter menempati sekitar 32×40 px di tengah, menyisakan padding untuk overshoot animasi.
- Pivot/anchor di tengah frame (digunakan untuk rotasi).
- Warna jas `#e8edf2` dengan shading `#a8b0bc`; kacamata teal `#14b8a6` untuk keterbacaan IFF.
- Siluet kuat — harus terbaca di atas lantai navy gelap pada skala 3×.

**Spesifikasi animasi:**
- **idle** (4 frame): pernapasan halus — ujung jas berayun, kepala bob 1 px. Loop.
- **walk** (4 frame): siklus 4-frame standar (contact, down, pass, up). Target 8 fps.
- **run** (4 frame): langkah lebih lebar, sedikit condong ke depan, jas berkibar. Target 12 fps.
- **collect** (5 frame, non-loop): gerakan membungkuk + mengambil. Diputar sekali per pickup.

**Konvensi arah:**
- north = menghadap atas, east = kanan, south = bawah (menghadap kamera), west = kiri.
- East/west adalah pasangan mirror — artis boleh menggambar satu dan membalik, tapi harus menyediakan kedua file.

### 8. `assets/tiles.png` — 64×16 RGBA (legacy)
**Kemungkinan sudah tidak digunakan.** Konfirmasi dengan dev. Jika dipertahankan: 4 tile × 16×16, manfaatkan kembali untuk props lingkungan (terminal komputer, rak beaker, rambu hazard, kisi ventilasi).

---

## Opsional / Stretch

- **Tekstur partikel** untuk kilap pengumpulan elemen (lingkaran putih 8×8 + kotak putih 4×4).
- **Vignette overlay** — saat ini berbasis shader; tidak perlu asset.
- **Sudut frame HUD** — bracket sudut 8×8 untuk dilapisi pada Panel sebagai tampilan frame terminal.
- **Decal lingkungan** — garis-garis hazard, simbol biohazard, props peralatan lab (atom 16×16) untuk disebar di lantai.

---

## Format Pengiriman

- PNG, RGBA, 8 bit/channel, tanpa premultiplied alpha.
- Tanpa metadata, tanpa color profile (atau hanya sRGB).
- Pixel-perfect — tanpa scaling, tanpa artefak upsampling.
- Nama file + path harus persis sama dengan tabel di atas. Godot akan reimport otomatis.
- Untuk Aseprite source: kirimkan file kerja `.aseprite` bersama ekspor PNG jika memungkinkan.

---

## Checklist Sanity (review mandiri artist sebelum handoff)

- [ ] Diperiksa pada zoom 1× dan 3× — terbaca di keduanya.
- [ ] Diuji di atas lantai gelap + dinding gelap — siluet terlihat jelas.
- [ ] Tanpa anti-aliasing pada tepi (matikan di tool).
- [ ] Latar transparan (alpha = 0 pada piksel latar, bukan putih/checker).
- [ ] Palette diambil dari spesifikasi — tanpa warna liar.
- [ ] Alignment grid 16 px untuk tile, pivot terpusat untuk sprite.
- [ ] Frame animasi dengan dimensi sama, pivot karakter stabil antar frame.
