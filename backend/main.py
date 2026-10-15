import os
import shutil
import math
import numpy as np

from fastapi import FastAPI, UploadFile, File, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import cv2

# Inisialisasi aplikasi FastAPI
app = FastAPI(
    title="Carein API",
    description="API Backend untuk analisis kondisi kulit wajah pada aplikasi Carein dengan OpenCV",
    version="2.0.0"
)

# Konfigurasi CORS agar API dapat diakses oleh Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}


# ─────────────────────────────────────────────────────────────────────────────
# Utilitas
# ─────────────────────────────────────────────────────────────────────────────

def _clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return float(max(lo, min(hi, float(value))))


def _level(value: float) -> str:
    """Konversi nilai 0–100 ke level teks."""
    if value < 35:
        return "Low"
    elif value < 65:
        return "Moderate"
    else:
        return "High"


def _load_image(path: str):
    """Baca gambar via PIL lalu konversi ke array BGR OpenCV."""
    pil_img = Image.open(path).convert("RGB")
    # Resize ke maksimal 800px di sisi terpanjang agar proses cepat
    max_dim = 800
    w, h = pil_img.size
    scale = min(max_dim / w, max_dim / h, 1.0)
    if scale < 1.0:
        pil_img = pil_img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
    img_rgb = np.array(pil_img, dtype=np.uint8)
    img_bgr = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)
    return img_bgr


# ─────────────────────────────────────────────────────────────────────────────
# Modul deteksi wajah (Haar Cascade bawaan OpenCV)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_face_region(img_bgr):
    """
    Coba deteksi area wajah dengan Haar cascade.
    Kembalikan crop BGR, atau gambar asli jika tidak terdeteksi.
    """
    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    cascade_path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    detector = cv2.CascadeClassifier(cascade_path)
    faces = detector.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80))

    if len(faces) == 0:
        return img_bgr  # Fallback: gunakan seluruh gambar

    # Ambil wajah terbesar
    faces = sorted(faces, key=lambda f: f[2] * f[3], reverse=True)
    x, y, w, h = faces[0]
    # Sedikit perbesar crop agar mencakup seluruh wajah
    pad = int(min(w, h) * 0.10)
    x1 = max(0, x - pad)
    y1 = max(0, y - pad)
    x2 = min(img_bgr.shape[1], x + w + pad)
    y2 = min(img_bgr.shape[0], y + h + pad)
    return img_bgr[y1:y2, x1:x2]


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi jerawat (Acne)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_acne(face_bgr) -> float:
    """
    Deteksi jerawat menggunakan dua teknik:
    1. Segmentasi warna kemerahan di ruang HSV
    2. SimpleBlobDetector untuk mendeteksi bintik/benjolan

    Mengembalikan skor 0–100.
    """
    h, w = face_bgr.shape[:2]
    total_pixels = h * w

    # ── Tahap 1: Deteksi area merah/kemerahan (jerawat meradang) ──────────────
    hsv = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2HSV)

    # Range warna merah kulit berjerawat (meradang)
    # Merah bawah (0–10°)
    lower_red1 = np.array([0, 40, 50])
    upper_red1 = np.array([10, 255, 255])
    # Merah atas (165–180°)
    lower_red2 = np.array([165, 40, 50])
    upper_red2 = np.array([180, 255, 255])

    mask_red1 = cv2.inRange(hsv, lower_red1, upper_red1)
    mask_red2 = cv2.inRange(hsv, lower_red2, upper_red2)
    mask_red = cv2.bitwise_or(mask_red1, mask_red2)

    # Hilangkan noise kecil
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask_red = cv2.morphologyEx(mask_red, cv2.MORPH_OPEN, kernel)
    mask_red = cv2.morphologyEx(mask_red, cv2.MORPH_CLOSE, kernel)

    red_pixel_ratio = cv2.countNonZero(mask_red) / total_pixels

    # ── Tahap 2: SimpleBlobDetector untuk menghitung jumlah bintik ─────────────
    gray = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (7, 7), 0)

    params = cv2.SimpleBlobDetector_Params()
    params.filterByArea = True
    params.minArea = max(30, total_pixels * 0.0005)
    params.maxArea = max(500, total_pixels * 0.008)
    params.filterByCircularity = True
    params.minCircularity = 0.3
    params.filterByConvexity = True
    params.minConvexity = 0.5
    params.filterByInertia = False

    detector = cv2.SimpleBlobDetector_create(params)
    keypoints = detector.detect(blurred)
    blob_count = len(keypoints)

    # Normalisasi blob ke skor
    # Anggap 0 blob = 0, 20+ blob = 100
    blob_score = min(blob_count / 20.0, 1.0)

    # ── Gabungkan dua sinyal ──────────────────────────────────────────────────
    # red_pixel_ratio: 0–~0.25 → 0–100
    red_score = min(red_pixel_ratio / 0.15, 1.0)

    # Bobot: 60% warna merah, 40% blob
    acne_score = (red_score * 0.60 + blob_score * 0.40) * 100
    return _clamp(acne_score)


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi keremangan kulit (Dullness)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_dullness(face_bgr) -> float:
    """
    Kulit kusam ditandai dengan kecerahan rendah dan saturasi warna rendah.
    Gunakan channel V (Value) di HSV dan S (Saturation).
    """
    hsv = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2HSV).astype(np.float32)
    saturation = hsv[:, :, 1]
    brightness = hsv[:, :, 2]

    mean_brightness = np.mean(brightness) / 255.0  # 0–1
    mean_saturation = np.mean(saturation) / 255.0  # 0–1

    # Dullness tinggi ketika brightness rendah & saturasi rendah
    # Kecerahan ideal: 0.6–0.85 → skor rendah
    brightness_dull = max(0, 0.70 - mean_brightness) / 0.70
    saturation_dull = max(0, 0.50 - mean_saturation) / 0.50

    dullness_score = (brightness_dull * 0.55 + saturation_dull * 0.45) * 100
    return _clamp(dullness_score)


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi bintik gelap (Dark Spots)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_dark_spots(face_bgr) -> float:
    """
    Bintik gelap terdeteksi sebagai area yang jauh lebih gelap dari kulit sekitar.
    Gunakan thresholding adaptif pada grayscale.
    """
    gray = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2GRAY)
    h, w = gray.shape
    total_pixels = h * w

    # Blur untuk memperhalus
    blurred = cv2.GaussianBlur(gray, (9, 9), 0)

    # Adaptive threshold → area lokal yang jauh lebih gelap
    thresh = cv2.adaptiveThreshold(
        blurred, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY_INV,
        blockSize=31,
        C=15
    )

    # Morphological filtering
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)

    dark_ratio = cv2.countNonZero(thresh) / total_pixels
    # dark_ratio: 0–~0.20 → skor 0–100
    dark_score = min(dark_ratio / 0.12, 1.0) * 100
    return _clamp(dark_score)


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi kemerahan (Redness)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_redness(face_bgr) -> float:
    """
    Kemerahan global berbeda dari jerawat: area difus yang luas berwarna merah/pink.
    """
    img_rgb = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2RGB).astype(np.float32)
    r = img_rgb[:, :, 0]
    g = img_rgb[:, :, 1]
    b = img_rgb[:, :, 2]

    # Indeks kemerahan: channel R dominan terhadap G dan B
    with np.errstate(divide='ignore', invalid='ignore'):
        redness_index = np.where(
            (g + b) > 0,
            (r - (g + b) / 2) / (np.maximum(r, 1)),
            0
        )
    mean_redness = float(np.mean(np.clip(redness_index, 0, 1)))
    # mean_redness: 0–~0.3 → skor 0–100
    redness_score = min(mean_redness / 0.25, 1.0) * 100
    return _clamp(redness_score)


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi oiliness (minyak)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_oiliness(face_bgr) -> float:
    """
    Kulit berminyak tampak berkilat → sorotan terang (specular highlight).
    Deteksi highlight terang di grayscale.
    """
    gray = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2GRAY)
    # Piksel sangat terang (>220) sebagai indikator kilat minyak
    highlight_mask = (gray > 220).astype(np.uint8)
    highlight_ratio = highlight_mask.sum() / gray.size
    # highlight_ratio: 0–~0.15 → skor 0–100
    oiliness_score = min(highlight_ratio / 0.08, 1.0) * 100
    return _clamp(oiliness_score)


# ─────────────────────────────────────────────────────────────────────────────
# Deteksi tekstur (Texture roughness)
# ─────────────────────────────────────────────────────────────────────────────

def _detect_texture(face_bgr) -> float:
    """
    Tekstur kasar menghasilkan banyak tepi (edges) dan varians lokal tinggi.
    Gunakan Laplacian untuk mengukur detail/frekuensi tinggi.
    """
    gray = cv2.cvtColor(face_bgr, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    laplacian = cv2.Laplacian(blurred, cv2.CV_64F)
    laplacian_var = float(np.var(laplacian))
    # laplacian_var: 0–~3000 → skor 0–100
    texture_score = min(laplacian_var / 2500.0, 1.0) * 100
    return _clamp(texture_score)


# ─────────────────────────────────────────────────────────────────────────────
# Hitung skin score keseluruhan
# ─────────────────────────────────────────────────────────────────────────────

def _calculate_skin_score(acne: float, dullness: float, dark_spot: float,
                           redness: float, oiliness: float, texture: float) -> int:
    """
    Skin Score: 100 dikurangi rata-rata tertimbang dari semua metrik masalah.
    Jerawat dan oiliness diberi bobot lebih tinggi.
    """
    weighted = (
        acne * 0.30 +
        oiliness * 0.20 +
        dullness * 0.15 +
        dark_spot * 0.15 +
        redness * 0.10 +
        texture * 0.10
    )
    score = 100 - weighted
    return max(0, min(100, round(score)))


# ─────────────────────────────────────────────────────────────────────────────
# Tentukan tipe kulit
# ─────────────────────────────────────────────────────────────────────────────

def _skin_type(oiliness: float, dullness: float) -> str:
    if oiliness >= 65:
        return "Oily"
    elif oiliness <= 30 and dullness >= 40:
        return "Dry"
    elif oiliness > 30 and oiliness < 65:
        return "Combination"
    else:
        return "Normal"


# ─────────────────────────────────────────────────────────────────────────────
# Generate AI Insight
# ─────────────────────────────────────────────────────────────────────────────

def _generate_insight(skin_type: str, acne: float, oiliness: float,
                       dullness: float, dark_spot: float, redness: float) -> str:
    parts = []

    if acne >= 55:
        parts.append("terdeteksi jerawat aktif yang cukup signifikan")
    elif acne >= 30:
        parts.append("ada sedikit jerawat atau komedo")

    if oiliness >= 60:
        parts.append("kulit tampak cukup berminyak terutama di area T-zone")

    if dullness >= 50:
        parts.append("warna kulit terlihat kurang cerah dan kusam")

    if dark_spot >= 45:
        parts.append("terdapat bintik gelap atau bekas jerawat yang terlihat")

    if redness >= 45:
        parts.append("terdeteksi kemerahan di beberapa area wajah")

    if not parts:
        return (
            f"Kondisi kulit Anda ({skin_type.lower()}) secara keseluruhan terlihat baik. "
            "Pertahankan rutinitas perawatan dan jaga kelembapan kulit."
        )

    base = f"Analisis menunjukkan kulit {skin_type.lower()}: " + ", ".join(parts) + ". "

    if skin_type == "Oily":
        base += "Gunakan pembersih berbasis salicylic acid dan hindari pelembap berbasis minyak."
    elif skin_type == "Dry":
        base += "Prioritaskan hidrasi dengan ceramide dan hindari produk beralkohol tinggi."
    elif skin_type == "Combination":
        base += "Seimbangkan rutinitas dengan pembersih lembut dan pelembap ringan oil-free."
    else:
        base += "Jaga rutinitas yang ada dan pertimbangkan sunscreen setiap pagi."

    return base


# ─────────────────────────────────────────────────────────────────────────────
# Endpoint
# ─────────────────────────────────────────────────────────────────────────────

@app.get("/")
def read_root():
    return {"status": "success", "message": "Carein API v2 (OpenCV) berjalan"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.post("/analyze")
async def analyze_face(file: UploadFile = File(...)):
    """
    Analisis kondisi kulit wajah dari foto yang diunggah menggunakan OpenCV.
    Mendeteksi: jerawat, keremangan, bintik gelap, kemerahan, oiliness, tekstur.
    """
    # Validasi nama file
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File foto tidak ditemukan atau nama file kosong."
        )

    # Validasi ekstensi
    _, ext = os.path.splitext(file.filename)
    if ext.lower() not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Format file tidak valid. Hanya menerima JPG, JPEG, dan PNG."
        )

    # Simpan file sementara
    saved_path = os.path.join(UPLOAD_DIR, file.filename)
    try:
        with open(saved_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal menyimpan file: {str(e)}"
        )

    # Load dan proses gambar
    try:
        img_bgr = _load_image(saved_path)
        face_bgr = _detect_face_region(img_bgr)

        acne = float(round(_detect_acne(face_bgr), 1))
        dullness = float(round(_detect_dullness(face_bgr), 1))
        dark_spot = float(round(_detect_dark_spots(face_bgr), 1))
        redness = float(round(_detect_redness(face_bgr), 1))
        oiliness = float(round(_detect_oiliness(face_bgr), 1))
        texture = float(round(_detect_texture(face_bgr), 1))

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Gagal memproses gambar: {str(e)}"
        )
    finally:
        # Hapus file upload setelah diproses
        try:
            os.remove(saved_path)
        except OSError:
            pass

    skin_type = _skin_type(oiliness, dullness)
    score = _calculate_skin_score(acne, dullness, dark_spot, redness, oiliness, texture)
    insight = _generate_insight(skin_type, acne, oiliness, dullness, dark_spot, redness)

    return {
        "status": "success",
        "message": "Analisis berhasil",
        "analysis": {
            "score": score,
            "skin_type": skin_type,
            "acne": acne,
            "dullness": dullness,
            "dark_spot": dark_spot,
            "redness": redness,
            "oiliness": oiliness,
            "texture": texture,
            "insight": insight,
            "metrics": [
                {"label": "Acne",     "value": acne,     "level": _level(acne)},
                {"label": "Oiliness", "value": oiliness, "level": _level(oiliness)},
                {"label": "Dryness",  "value": dullness, "level": _level(dullness)},
                {"label": "Spots",    "value": dark_spot,"level": _level(dark_spot)},
                {"label": "Texture",  "value": texture,  "level": _level(texture)},
            ],
        },
    }