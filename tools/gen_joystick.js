const fs = require('fs');
const zlib = require('zlib');

function makePNG(width, height, pixels) {
    const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

    function chunk(type, data) {
        const buf = Buffer.alloc(4 + type.length + data.length + 4);
        buf.writeUInt32BE(data.length, 0);
        buf.write(type, 4);
        data.copy(buf, 4 + type.length);
        const crc = crc32(Buffer.concat([Buffer.from(type), data]));
        buf.writeInt32BE(crc, buf.length - 4);
        return buf;
    }

    // IHDR
    const ihdr = Buffer.alloc(13);
    ihdr.writeUInt32BE(width, 0);
    ihdr.writeUInt32BE(height, 4);
    ihdr[8] = 8; // bit depth
    ihdr[9] = 6; // RGBA
    ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

    // IDAT
    const raw = Buffer.alloc(height * (1 + width * 4));
    for (let y = 0; y < height; y++) {
        raw[y * (1 + width * 4)] = 0; // filter none
        for (let x = 0; x < width; x++) {
            const si = (y * width + x) * 4;
            const di = y * (1 + width * 4) + 1 + x * 4;
            raw[di] = pixels[si];
            raw[di + 1] = pixels[si + 1];
            raw[di + 2] = pixels[si + 2];
            raw[di + 3] = pixels[si + 3];
        }
    }
    const compressed = zlib.deflateSync(raw);

    // IEND
    const iend = Buffer.alloc(0);

    return Buffer.concat([
        signature,
        chunk('IHDR', ihdr),
        chunk('IDAT', compressed),
        chunk('IEND', iend)
    ]);
}

function crc32(buf) {
    let table = [];
    for (let n = 0; n < 256; n++) {
        let c = n;
        for (let k = 0; k < 8; k++) {
            c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
        }
        table[n] = c;
    }
    let crc = 0xFFFFFFFF;
    for (let i = 0; i < buf.length; i++) {
        crc = table[(crc ^ buf[i]) & 0xFF] ^ (crc >>> 8);
    }
    return (crc ^ 0xFFFFFFFF);
}

// === JOYSTICK BASE (64x64) ===
function genBase() {
    const size = 64;
    const pixels = Buffer.alloc(size * size * 4);
    const cx = size / 2, cy = size / 2;
    const outerR = 30;
    const innerR = 28;

    for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
            const i = (y * size + x) * 4;
            const dx = x - cx + 0.5, dy = y - cy + 0.5;
            const dist = Math.sqrt(dx * dx + dy * dy);

            if (dist > outerR + 1) {
                // Outside circle - transparent
                pixels[i] = 0; pixels[i+1] = 0; pixels[i+2] = 0; pixels[i+3] = 0;
            } else if (dist > outerR) {
                // Anti-alias outer edge
                const aa = outerR + 1 - dist;
                pixels[i] = 0; pixels[i+1] = 180; pixels[i+2] = 220;
                pixels[i+3] = Math.round(80 * aa);
            } else if (dist > innerR) {
                // Border ring - cyan glow
                const t = (dist - innerR) / (outerR - innerR);
                pixels[i] = 0;
                pixels[i+1] = Math.round(150 + 50 * t);
                pixels[i+2] = Math.round(200 + 55 * t);
                pixels[i+3] = Math.round(80 + 20 * t);
            } else {
                // Inner fill - dark semi-transparent
                const t = dist / innerR;
                pixels[i] = Math.round(15 + 10 * t);
                pixels[i+1] = Math.round(15 + 15 * t);
                pixels[i+2] = Math.round(35 + 20 * t);
                pixels[i+3] = Math.round(60 + 15 * t);
            }
        }
    }
    return makePNG(size, size, pixels);
}

// === JOYSTICK HANDLE (32x32) ===
function genHandle() {
    const size = 32;
    const pixels = Buffer.alloc(size * size * 4);
    const cx = size / 2, cy = size / 2;
    const radius = 13;

    for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
            const i = (y * size + x) * 4;
            const dx = x - cx + 0.5, dy = y - cy + 0.5;
            const dist = Math.sqrt(dx * dx + dy * dy);

            if (dist > radius + 1) {
                pixels[i] = 0; pixels[i+1] = 0; pixels[i+2] = 0; pixels[i+3] = 0;
            } else {
                const t = Math.min(dist / radius, 1.0);
                let alpha;
                if (dist > radius) {
                    alpha = (radius + 1 - dist) * 220;
                } else {
                    alpha = 220;
                }
                // Radial gradient: white center → cyan edge
                pixels[i] = Math.round(255 * (1 - t * 0.6));     // R: 255 → 102
                pixels[i+1] = Math.round(255 * (1 - t * 0.15));  // G: 255 → 217
                pixels[i+2] = 255;                                  // B: always 255
                pixels[i+3] = Math.round(Math.max(0, Math.min(255, alpha)));
            }
        }
    }
    return makePNG(size, size, pixels);
}

const spritesDir = __dirname + '/../assets/sprites';
fs.writeFileSync(spritesDir + '/joystick_base.png', genBase());
fs.writeFileSync(spritesDir + '/joystick_handle.png', genHandle());
console.log('Generated joystick_base.png (64x64) and joystick_handle.png (32x32)');
