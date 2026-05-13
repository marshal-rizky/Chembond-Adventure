# ChemBond Adventure — Dokumen Handoff
**Terakhir diperbarui:** 2026-05-06

---

## Apa Ini

Game maze kimia 2D top-down dengan pixel art. Pemain menavigasi ASCII maze, mengumpulkan atom elemen yang tepat untuk membentuk molekul, lalu keluar melalui gate. Gate hanya terbuka **jika inventory persis cocok** — atom yang salah akan menguncinya.

**Engine:** Godot 4.6 · **Bahasa:** GDScript · **Platform:** Desktop + Web + Touch

**Live:** https://chembondadventure.vercel.app · **Repo:** https://github.com/marshal-rizky/Chembond-Adventure

---

## Tiga Mode

| Mode | Deskripsi |
|---|---|
| **Normal** | 10 level (H₂O → CH₃COOH). Maze 20×15, skala 3×. Jumlah decoy meningkat seiring level. |
| **Tutorial** | H₂O saja. Tutorial interaktif 5 langkah dengan gating — atom bersinar, muncul peringatan jika salah ambil decoy. |
| **Legend** | 3 level ultra-sulit (Glucose, Ca-Phosphate, Al-Sulfate). Maze 30×20, skala 2×. Mekanik dual-player mirror — pemain kanan mencerminkan input sumbu x pemain kiri. Keduanya harus mencapai center gate bersamaan. |

---

## Arsitektur

- **Autoloads:** `GameManager` (flag state level/mode) · `AudioManager` (sfx + music)
- **Entry:** `main_menu.tscn` → `main.tscn` (semua di-spawn saat runtime)
- **Maze:** Layout ASCII di `maze_manager.gd`, di-parse menjadi TileMapLayer + dinding StaticBody2D saat load
- **Pathfinding:** BFS di `level_generator.gd` — memvalidasi rencana spawn, memastikan level bisa diselesaikan
- **Signals:** `element.collected` → `player.collected_signal` → `main._on_player_collected` → `gate.check_requirements`

---

## Identitas Visual

**Tema:** Lab kimia terbengkalai dalam kondisi lockdown. Estetika System Shock / Alien.

**Palette:** Navy gelap `#070b14` · aksen teal `#14b8a6` · teal-hi `#5eead4` · teks `#cfeae6`

**Player:** Karakter ilmuwan, frame 48×48, 4 arah × animasi idle/walk/run/collect via `scientist.tres` SpriteFrames.

**Tileset:** Wang tileset `assets/tiles_wang.png` — dinding di cell (0,3), lantai di (2,1).

**Font:** Pixelify Sans (`assets/fonts/PixelifySans-Regular.ttf`), dimuat via `UITheme.create_game_theme()`.

---

## Status Saat Ini (2026-05-13)

**Sudah selesai dan dirilis:**
- Semua 10 level normal + tutorial + 3 level legend — sepenuhnya playable
- Interaktivitas tutorial — langkah-langkah bertahap, sorotan glow pada atom, peringatan decoy
- Polish visual — font Pixelify Sans, grid shader di menu, ikon tombol HUD (↺ ✕ →), baris logo main menu
- AnimatedSprite ilmuwan dengan animasi walk/run/idle/collect per arah
- Vignette shader (tint merah gelap), screen shake, partikel trail
- Element pickup didesain ulang sebagai hex chip pixel art via `_draw()` — tanpa sprite, bobbing + glow pulse tetap ada
- Panel tutorial direstyling sesuai estetika HUD — latar gelap, border teal atas, titik progres langkah, tombol OK bergaya
- Ghost atom di main menu — 35 simbol elemen besar (α 0.12–0.22), didistribusikan grid 7×5, melayang pelan
- Web deployment via Vercel + GitHub Actions CI/CD — auto deploy setiap push ke `main`
- Komentar kode Bahasa Indonesia di semua 12 file `.gd`

**Perbaikan di sesi terakhir (2026-05-13):**
- Fix layout maze Legend I, II, III — semua interior row diperpanjang dari 29 → 30 karakter (border kanan hilang)
- Fix Legend I: dinding di (5,9) memutus jalur start kiri ke exit, plus 3 pocket terisolasi di area kanan bawah
- Fix Legend II: pocket terisolasi 4 tile di (8-9,11-12), tile border terisolasi di (28,8)
- Fix Legend III: sisi kanan maze terputus total dari sisi kiri (59/267 tile reachable), tile border terisolasi di (28,8)
- Semua 3 legend maze diverifikasi fully connected via BFS — kedua player bisa reach semua tile dan exit
- Git history di-squash dari 56 → 9 commits bersih, timestamps asli, semua author marshal Rizky
- Repo dipindah ke `Chembond-Adventure`, Vercel reconnected

**Masalah yang diketahui:**
- `legend_unlocked = true` di-hardcode — sebaiknya dikunci di balik penyelesaian level 9 sebelum rilis
- Level selector terpotong di monitor 1366×768 — window 1280×720 tapi title bar + taskbar hanya menyisakan sekitar 698px tinggi, memotong baris bawah. Solusi: tambahkan `window/size/mode=2` (maximized) ke `project.godot`, atau geser offset LevelSelector ke atas 25px (`offset_top=-85`, `offset_bottom=-45`)

---

## File-file Utama

| File | Fungsi |
|---|---|
| `assets/questions.json` | Semua 13 soal level (10 normal + 3 legend, `"legend": true`) |
| `scripts/game_manager.gd` | Flag mode: `is_tutorial`, `is_legend_mode`, `legend_level` |
| `scripts/maze_manager.gd` | Semua layout ASCII maze + fungsi load + validasi spawn |
| `scripts/level_generator.gd` | Helper BFS statis |
| `scripts/player.gd` | Pergerakan, pengumpulan, state machine animasi, mirror input |
| `scripts/tutorial_manager.gd` | Urutan tutorial 5 langkah dengan gating |
| `scripts/ui_theme.gd` | Konstanta warna + `create_game_theme()` |
| `design/art-spec.md` | Spesifikasi asset pixel art (ukuran, palette, format pengiriman) |
| `.github/workflows/deploy.yml` | CI/CD: Godot headless export → Vercel Build Output API deploy |
| `vercel.json` | Header COOP/COEP + WASM MIME type untuk web export |
| `export_presets.cfg` | Godot Web export preset (nothreads, custom HTML shell) |
| `export/custom_html_shell.html` | HTML shell dengan mobile viewport meta tag |

---

## Deployment

**Stack:** GitHub Actions → Godot 4.6.2 headless export (nothreads) → Vercel Build Output API (`--prebuilt`)

**Alur:** Push ke `main` → Actions checkout + download Godot + export templates → `godot --headless --export-release "Web" build/index.html` → copy ke `.vercel/output/static/` → `vercel deploy --prebuilt --prod`

**Secrets GitHub (repo Chembond-Adventure):**
- `VERCEL_TOKEN` — token akses Vercel
- `VERCEL_ORG_ID` — team ID (`team_DYj1pVWwz6DRut4yhXYXjak4`)
- `VERCEL_PROJECT_ID` — project ID (`prj_5pWLhmIrIuQyJNmOBACbZL90iKXe`)

**Catatan:**
- Pakai variant `nothreads` agar kompatibel iOS Safari (tidak butuh SharedArrayBuffer)
- Header COOP/COEP tetap di-set di `vercel.json` sebagai belt-and-suspenders
- Custom HTML shell menambah `<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">`

---

## Rencana ke Depan

- Kunci mode Legend di balik penyelesaian level 9 (flag `legend_unlocked`)
- Perbaikan sound design — SFX saat ini masih placeholder
- Mobile export — input touch sudah terhubung via virtual joystick
- Leaderboard / pelacakan waktu per level (belum ada backend)
- Tambah level legend (3 → 5+)
