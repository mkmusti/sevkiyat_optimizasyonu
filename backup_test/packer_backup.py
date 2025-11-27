# app/core/packer.py
from typing import List, Tuple, Optional
from ..models import Item as RequestItem, Bin as RequestBin, PackedItem, PackedBin
from py3dbp import Packer, Bin, Item

# Kendi görselleştirme modülümüzü import ediyoruz
from .visualizer import Visualization3D

class BinPacker:
    """
    Gerçek 3D Optimizasyon Motoru (py3dbp)
    Sonsuz Döngü Düzeltmesi (V6) + Özel Görselleştirme
    """

    def __init__(self):
        # Görselleştiriciyi başlat
        self.visualizer = Visualization3D()

    def pack(self, 
             items: List[RequestItem], 
             bins: List[RequestBin], 
             algoritma: str, 
             gorsel_olustur: bool
             ) -> Tuple[List[PackedBin], List[str]]:
        
        print(f"[Packer] Gelen 'items' (gruplu): {len(items)} tip.")
        print(f"[Packer] İstenen algoritma: {algoritma}")
        print(f"[Packer] Görsel oluştur: {gorsel_olustur}")

        # --- 1. TÜM KOLİLERİ OLUŞTUR (GENİŞLET) ---
        items_to_pack_dict = {} 
        total_items_to_pack_count = 0
        
        for item in items: 
            quantity = getattr(item, 'quantity', 1)
            for i in range(quantity):
                item_id = f"{item.id}_{i}"
                items_to_pack_dict[item_id] = (Item(
                    name=item_id, 
                    width=item.width,
                    height=item.height,
                    depth=item.length,
                    weight=item.weight
                ))
            total_items_to_pack_count += quantity
        
        print(f"[Packer] Toplam {total_items_to_pack_count} (genişletilmiş) koli yerleştirilecek.")

        # --- 2. KULLANILACAK ARACI BELİRLE ---
        if not bins:
            raise Exception("API'ye hiç 'bin' (araç) gönderilmedi.")
        
        largest_bin_spec = max(bins, key=lambda b: b.volume)
        print(f"[Packer] Ana araç olarak en büyük araç seçildi: {largest_bin_spec.id}")

        # --- 3. "TEK TEK DOLDUR" DÖNGÜSÜ ---
        packed_bins_response: List[PackedBin] = []
        bin_index = 0
        
        # 'yerlestirilecek_idler' artık ID'leri tutan bir Set (küme) olacak.
        yerlestirilecek_idler = set(items_to_pack_dict.keys())

        while len(yerlestirilecek_idler) > 0:
            bin_index += 1
            current_bin_name = f"{largest_bin_spec.id}_{bin_index}" # t1_1, t1_2...
            print(f"\n[Packer] Döngü {bin_index}: Yeni araç alınıyor ({current_bin_name})...")
            print(f"[Packer] Kalan koli sayısı: {len(yerlestirilecek_idler)}")
            
            packer = Packer()
            packer.add_bin(Bin(
                name=current_bin_name,
                width=largest_bin_spec.width,
                height=largest_bin_spec.height,
                depth=largest_bin_spec.length, 
                max_weight=largest_bin_spec.max_weight
            ))

            # Kalan tüm kolileri (sadece ID'si kalanları) motora ekle
            for item_id in yerlestirilecek_idler:
                packer.add_item(items_to_pack_dict[item_id])

            print(f"[Packer] {len(yerlestirilecek_idler)} koli için 3D hesaplama başlıyor...")
            
            packer.pack(
                bigger_first=True, 
                distribute_items=False 
            )

            packed_bin_3d = packer.bins[0] # O anki Tır
            
            if not packed_bin_3d.items:
                print(f"[Packer] HATA: Kalan koliler boş Tır'a ({current_bin_name}) sığmıyor!")
                break # Döngüden çık
                
            print(f"[Packer] Araç {current_bin_name} dolduruldu. İçindeki koli: {len(packed_bin_3d.items)}")

            # Yanıt için Tır'ı ve içindekileri formatla
            packed_items_response: List[PackedItem] = []
            
            # --- ANA LİSTEYİ MANUEL GÜNCELLE (SONSUZ DÖNGÜ DÜZELTMESİ) ---
            packed_item_ids_this_run = set() # Bu Tır'a yerleşenlerin ID'leri
            
            for item in packed_bin_3d.items:
                packed_items_response.append(PackedItem(
                    item_id=item.name, 
                    position=tuple(float(pos) for pos in item.position), 
                    dimensions=tuple([float(d) for d in item.get_dimension()]) 
                ))
                packed_item_ids_this_run.add(item.name) # ID'yi sete ekle
            
            # Ana listeden (yerlestirilecek_idler), bu Tır'a yerleşenleri (packed_item_ids_this_run) ÇIKAR
            yerlestirilecek_idler.difference_update(packed_item_ids_this_run)
            # --- DÜZELTME BİTTİ ---
            
            # --- GÖRSEL OLUŞTURMA (KENDİ GÖRSELLEŞTİRİCİMİZ) ---
            visual_path = None
            if gorsel_olustur:
                try:
                    output_filename = f"app/outputs/{current_bin_name}.png"
                    print(f"[Packer] Görsel oluşturma deneniyor: {output_filename}")
                    
                    # KENDİ 3D GÖRSELLEŞTİRİCİMİZİ KULLAN
                    result_path = self.visualizer.create_3d_visualization(
                        bin_obj=packed_bin_3d,
                        output_path=output_filename
                    )
                    
                    if result_path:
                        print(f"[Packer] Görsel başarıyla oluşturuldu: {result_path}")
                        visual_path = f"/outputs/{current_bin_name}.png"
                    else:
                        print(f"[Packer] Görsel oluşturma BAŞARISIZ")
                        visual_path = None
                        
                except Exception as e:
                    print(f"!!! GÖRSELLEŞTİRME HATASI: {e}")
                    import traceback
                    print(f"!!! Traceback: {traceback.format_exc()}")
                    visual_path = None

            total_item_volume = sum(item.get_volume() for item in packed_bin_3d.items)
            utilization = round((total_item_volume / packed_bin_3d.get_volume()) * 100, 2)
            total_weight = sum(item.weight for item in packed_bin_3d.items) 

            packed_bins_response.append(PackedBin(
                bin_id=packed_bin_3d.name,
                items=packed_items_response,
                utilization_percent=utilization,
                weight_used=total_weight,
                visual_path=visual_path
            ))
        # --- DÖNGÜ BİTTİ ---

        unpacked_items_response: List[str] = list(yerlestirilecek_idler)
        print(f"\n[Packer] TÜM HESAPLAMA TAMAMLANDI.")
        print(f"[Packer] Toplam {len(packed_bins_response)} araç kullanıldı.")
        print(f"[Packer] Yerleşemeyen toplam koli sayısı: {len(unpacked_items_response)}")

        return packed_bins_response, unpacked_items_response