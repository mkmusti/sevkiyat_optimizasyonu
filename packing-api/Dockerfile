# 1. Temel imaj olarak KÜÇÜK olan "slim" sürümünü kullan
FROM python:3.11-slim

# Güvenlik güncellemelerini al
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Çalışma dizinini /app olarak ayarla
WORKDIR /app

# 3. Bağımlılık dosyasını kopyala
COPY requirements.txt .

# 4. Bağımlılıkları yükle (google-cloud-storage dahil)
RUN pip install --no-cache-dir -r requirements.txt

# 5. 'app' paketinizin tamamını (.py dosyaları) kopyala
COPY ./app ./app

# 6. 'mkdir -p app/outputs' satırı SİLİNDİ (Artık GCS kullanıyoruz)

# 7. Cloud Run'ın hangi portu dinleyeceğini belirt
ENV PORT 8080

# 8. Konteyner başladığında API'yi başlatacak komut
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port $PORT"]