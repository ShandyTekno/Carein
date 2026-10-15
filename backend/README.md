# AISKIN Backend — Cara Menjalankan

## Instalasi (pertama kali)

```bash
cd backend
# Aktifkan virtual environment
.\venv\Scripts\activate       # Windows
# atau: source venv/bin/activate  (Mac/Linux)

# Install semua dependencies (termasuk OpenCV)
pip install -r requirements.txt
```

## Menjalankan server

```bash
.\venv\Scripts\uvicorn main:app --reload --port 8000
```

Server berjalan di: http://localhost:8000  
Dokumentasi API: http://localhost:8000/docs

## Catatan host untuk Flutter

Edit `lib/services/api_service.dart` → `ApiConfig._host`:

| Platform | Nilai `_host` |
|---|---|
| Web / Desktop (Windows) | `localhost` |
| Emulator Android | `10.0.2.2` |
| Device fisik | IP LAN komputer (mis. `192.168.1.5`) |

---

 API

Backend REST API sederhana untuk aplikasi **AISKIN** menggunakan Python dan FastAPI.

---

## 📁 Struktur Direktori

```text
backend/
├── main.py            # Logika utama aplikasi FastAPI dan endpoint API
├── requirements.txt   # Daftar dependensi Python yang dibutuhkan
├── uploads/           # Folder penyimpanan sementara foto yang diunggah
└── README.md          # Petunjuk instalasi dan cara menjalankan server
```

---

## 🚀 Cara Menjalankan Backend di Windows

Buka terminal (Command Prompt atau PowerShell), lalu jalankan perintah berikut secara berurutan:

### 1. Masuk ke direktori backend
```powershell
cd backend
```

### 2. Buat virtual environment Python
```powershell
python -m venv venv
```

### 3. Aktifkan virtual environment
```powershell
venv\Scripts\activate
```

> **Catatan:** Jika muncul pesan error execution policy di PowerShell, Anda dapat menjalankan perintah berikut terlebih dahulu:
> `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`

### 4. Install dependensi
```powershell
pip install -r requirements.txt
```

### 5. Jalankan server FastAPI
```powershell
uvicorn main:app --reload
```

Server akan aktif dan dapat diakses di:
👉 **http://127.0.0.1:8000**

---

## 📖 Dokumentasi Interaktif API (Swagger UI)

FastAPI menyediakan dokumentasi interaktif otomatis yang dapat langsung diakses melalui browser:
- Swagger UI: **http://127.0.0.1:8000/docs**
- ReDoc: **http://127.0.0.1:8000/redoc**

---

## 🔌 Daftar Endpoint

### 1. Root Endpoint (`GET /`)
Memeriksa status aktif API AISKIN.
- **URL**: `http://127.0.0.1:8000/`
- **Method**: `GET`
- **Response**:
```json
{
  "status": "success",
  "message": "AISKIN API berjalan"
}
```

---

### 2. Health Check (`GET /health`)
Memeriksa kesehatan server.
- **URL**: `http://127.0.0.1:8000/health`
- **Method**: `GET`
- **Response**:
```json
{
  "status": "ok"
}
```

---

### 3. Analisis Foto Wajah (`POST /analyze`)
Menerima file foto wajah dari aplikasi Flutter menggunakan format `multipart/form-data`.
- **URL**: `http://127.0.0.1:8000/analyze`
- **Method**: `POST`
- **Body**: `multipart/form-data`
  - `file`: File gambar wajah (format `.jpg`, `.jpeg`, atau `.png`)
- **Response Success (200 OK)**:
```json
{
  "status": "success",
  "message": "Analisis berhasil",
  "analysis": {
    "acne": 65,
    "dullness": 40,
    "dark_spot": 20,
    "redness": 15
  },
  "recommendations": [
    {
      "name": "Gentle Cleanser",
      "category": "Cleanser"
    },
    {
      "name": "Acne Treatment",
      "category": "Treatment"
    },
    {
      "name": "Sunscreen SPF 50",
      "category": "Sunscreen"
    }
  ]
}
```
- **Response Error (400 Bad Request)** jika format file tidak sesuai:
```json
{
  "detail": "Format file tidak valid. Hanya menerima file JPG, JPEG, dan PNG."
}
```
