# packing-api/app/models.py
from pydantic import BaseModel
from typing import List, Tuple, Optional

# --- BU DOSYA ARTIK TÜM MODELLER İÇİN TEK KAYNAK OLACAK ---

class Item(BaseModel):
    """API'nin beklediği Koli modeli"""
    id: str
    ad: Optional[str] = None # 422 Hatası için isteğe bağlı yapıldı
    width: float
    height: float
    length: float
    weight: float
    quantity: int = 1

class Bin(BaseModel):
    """API'nin beklediği Araç modeli"""
    id: str
    ad: Optional[str] = None # 422 Hatası için isteğe bağlı yapıldı
    width: float
    height: float
    length: float
    max_weight: float

    @property
    def volume(self):
        return self.width * self.height * self.length

class PackedItem(BaseModel):
    """API'nin döndüreceği yerleşmiş Koli"""
    item_id: str
    position: Tuple[float, float, float]
    dimensions: Tuple[float, float, float]

class PackedBin(BaseModel):
    """API'nin döndüreceği dolu Araç"""
    bin_id: str
    items: List[PackedItem]
    utilization_percent: float
    weight_used: float
    visual_path: Optional[str] = None

class PackRequest(BaseModel):
    """/optimize endpoint'inin beklediği JSON gövdesi"""
    items: List[Item]
    bins: List[Bin]
    algoritma: str = "default"
    gorsel_olustur: bool = True

class PackResponse(BaseModel):
    """API'nin döndüreceği yanıt"""
    packed_bins: List[PackedBin]
    unpacked_items: List[str]