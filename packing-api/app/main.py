# packing-api/app/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uuid
import traceback

# DÜZELTME: Modelleri 'app.models' dosyasından import et
from .models import PackRequest, PackResponse

# core.packer da 'app.models' dosyasından import ettiği için
# artık iki dosya da aynı sınıfları kullanacak.
from .core.packer import BinPacker

app = FastAPI()

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    """API'nin çalışıp çalışmadığını kontrol eder."""
    return {"status": "Sevkiyat Optimizasyon API çalışıyor!"}

@app.post("/optimize", response_model=PackResponse)
def optimize_packing(request: PackRequest):
    try:
        session_id = str(uuid.uuid4())[:8]
        print(f"[MainAPI] Oturum ID: {session_id} ile optimizasyon çağrıldı.")

        # Packer motoru, fonksiyon içinde, istek geldiğinde oluşturulur.
        packer_engine = BinPacker()

        # planla_ve_gorsellestir fonksiyonu çağrılır
        packed_bins, unpacked_items = packer_engine.planla_ve_gorsellestir(
            session_id=session_id,
            items=request.items,
            bins=request.bins,
            algoritma=request.algoritma,
            gorsel_olustur=request.gorsel_olustur
        )

        return PackResponse(
            packed_bins=packed_bins,
            unpacked_items=unpacked_items
        )

    except Exception as e:
        print(f"!!! KRİTİK HATA: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Optimizasyon sırasında sunucu hatası: {str(e)}")