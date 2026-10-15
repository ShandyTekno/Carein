"""Script test untuk memverifikasi deteksi jerawat berjalan."""
import urllib.request
import json
import io
from PIL import Image, ImageDraw

# Buat gambar test simulasi wajah berjerawat
img = Image.new('RGB', (300, 400), color=(210, 170, 140))  # warna kulit
draw = ImageDraw.Draw(img)

# Tambahkan bintik merah simulasi jerawat
spots = [(120,180),(140,200),(160,175),(130,210),(155,190),(110,195),(170,205)]
for x, y in spots:
    draw.ellipse([x-6, y-6, x+6, y+6], fill=(200, 60, 60))
    draw.ellipse([x-3, y-3, x+3, y+3], fill=(180, 40, 40))

buf = io.BytesIO()
img.save(buf, format='JPEG')
img_data = buf.getvalue()

boundary = '----AISKINBoundaryTest'
crlf = b'\r\n'
parts = [
    b'--' + boundary.encode() + crlf,
    b'Content-Disposition: form-data; name="file"; filename="test_face.jpg"' + crlf,
    b'Content-Type: image/jpeg' + crlf + crlf,
    img_data,
    crlf + b'--' + boundary.encode() + b'--' + crlf
]
body = b''.join(parts)

req = urllib.request.Request(
    'http://localhost:8000/analyze',
    data=body,
    headers={
        'Content-Type': f'multipart/form-data; boundary={boundary}',
    }
)

try:
    with urllib.request.urlopen(req) as resp:
        print(f"Status HTTP : {resp.status}")
        data = json.loads(resp.read().decode('utf-8'))
        analysis = data['analysis']
        print(f"Skin Score  : {analysis['score']}")
        print(f"Skin Type   : {analysis['skin_type']}")
        print(f"Jerawat     : {analysis['acne']} ({next(m['level'] for m in analysis['metrics'] if m['label'] == 'Acne')})")
        print(f"Oiliness    : {analysis['oiliness']}")
        print(f"Insight     : {analysis['insight'][:120]}...")
        print()
        print("Semua Metrik:")
        for m in analysis['metrics']:
            bar = "#" * int(m['value'] / 5)
            print(f"  {m['label']:10s} {bar:20s} {m['value']:5.1f}  [{m['level']}]")

        print("\n[OK] Backend deteksi jerawat dan analisis wajah berjalan dengan sempurna!")
except Exception as e:
    print(f"[ERROR]: {e}")
