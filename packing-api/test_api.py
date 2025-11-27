import requests
import json

def test_api():
    url = "http://localhost:8000/optimize?algoritma=3d&gorsel_olustur=true"
    
    data = {
        "items": [
            {"id": "koli1", "width": 100, "height": 50, "length": 80, "weight": 10, "quantity": 3},
            {"id": "koli2", "width": 60, "height": 40, "length": 70, "weight": 5, "quantity": 2},
            {"id": "koli3", "width": 120, "height": 60, "length": 90, "weight": 15, "quantity": 1}
        ],
        "bins": [
            {"id": "tir1", "width": 300, "height": 200, "length": 800, "max_weight": 2000}
        ]
    }
    
    try:
        print(" API Testi başlıyor...")
        response = requests.post(url, json=data)
        
        print(f" Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(" BAŞARILI! API cevabı:")
            print(json.dumps(result, indent=2, ensure_ascii=False))
            
            # Görsel yollarını kontrol et
            packed_bins = result.get('packed_bins', [])
            for bin in packed_bins:
                if bin.get('visual_path'):
                    print(f" Görsel oluşturuldu: {bin['visual_path']}")
                    
        else:
            print(f" HATA: {response.text}")
            
    except Exception as e:
        print(f" Exception: {e}")

if __name__ == "__main__":
    test_api()
