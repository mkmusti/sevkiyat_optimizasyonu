# app/core/packer.py
from typing import List, Tuple, Optional
from ..models import Item as RequestItem, Bin as RequestBin, PackedItem, PackedBin
from py3dbp import Packer, Bin, Item
import sys
import gc # Hafıza temizliği için

# Doğru görselleştirici dosyasını (visualizer_threejs.py) import et
from .visualizer_threejs import Visualization3D

class BinPacker:
    """
    Gerçek 3D Optimizasyon Motoru (py3dbp)
    GCS Entegrasyonu ile "Stateless" Tasarım
    """

    def __init__(self):
        # Görselleştiriciyi başlat
        self.visualizer = Visualization3D()

    # GCS çakışmalarını önlemek için session_id alan fonksiyonu kullan
    def planla_ve_gorsellestir(self,
                               session_id: str,
                               items: List[RequestItem],
                               bins: List[RequestBin],
                               algoritma: str,
                               gorsel_olustur: bool
                               ) -> Tuple[List[PackedBin], List[str]]:

        print(f"[Packer] Oturum {session_id}: Hesaplama başlıyor.")
        print(f"[Packer] Gelen 'items' (gruplu): {len(items)} tip.")
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
                    height=item.length, # Eksen Düzeltmesi (W, L, H)
                    depth=item.height,  # Eksen Düzeltmesi (W, L, H)
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

        yerlestirilecek_idler = set(items_to_pack_dict.keys())

        while len(yerlestirilecek_idler) > 0:
            bin_index += 1
            # KRİTİK: Dosya adını benzersiz hale getir (GCS çakışmasını önler)
            current_bin_name = f"{session_id}_{largest_bin_spec.id}_{bin_index}"
            print(f"\n[Packer] Döngü {bin_index}: Yeni araç alınıyor ({current_bin_name})...")
            print(f"[Packer] Kalan koli sayısı: {len(yerlestirilecek_idler)}")

            packer = Packer() # Her döngüde yeni bir Packer nesnesi oluşturulur.
            packer.add_bin(Bin(
                name=current_bin_name,
                width=largest_bin_spec.width,
                height=largest_bin_spec.length, # Eksen Düzeltmesi
                depth=largest_bin_spec.height,  # Eksen Düzeltmesi
                max_weight=largest_bin_spec.max_weight
            ))

            for item_id in yerlestirilecek_idler:
                packer.add_item(items_to_pack_dict[item_id])

            print(f"[Packer] {len(yerlestirilecek_idler)} koli için 3D hesaplama başlıyor...")

            packer.pack(
                bigger_first=True,
                distribute_items=False
            )

            packed_bin_3d = packer.bins[0]

            if not packed_bin_3d.items:
                print(f"[Packer] HATA: Kalan koliler boş Tır'a ({current_bin_name}) sığmıyor!")
                del packer
                gc.collect()
                break

            print(f"[Packer] Araç {current_bin_name} dolduruldu. İçindeki GERÇEK YERLEŞİM: {len(packed_bin_3d.items)}")

            # Bu tırın yanıt listesini oluştur
            current_packed_items: List[PackedItem] = []
            packed_item_ids_this_run = set()

            for item in packed_bin_3d.items:
                current_packed_items.append(PackedItem(
                    item_id=item.name,
                    position=tuple(float(pos) for pos in item.position),
                    dimensions=tuple([float(d) for d in item.get_dimension()])
                ))
                packed_item_ids_this_run.add(item.name)

            yerlestirilecek_idler.difference_update(packed_item_ids_this_run)

            # --- GÖRSEL OLUŞTURMA (GCS'YE YÜKLEME) ---
            visual_path = None
            if gorsel_olustur:
                try:
                    # Dosya adı zaten session_id'yi içeriyor, bu sayede çakışma olmaz
                    gcs_file_name = f"{current_bin_name}.html"
                    print(f"[Packer] Görsel GCS'ye yükleniyor: {gcs_file_name}")

                    # Visualizer'ı çağır. Bu, tam GCS URL'sini döndürmelidir.
                    public_url = self.visualizer.create_3d_visualization(
                        bin_obj=packed_bin_3d,
                        output_path=gcs_file_name
                    )

                    if public_url:
                        print(f"[Packer] Görsel başarıyla oluşturuldu: {public_url}")
                        visual_path = public_url # Dönen tam URL'yi ata
                    else:
                        print(f"[Packer] Görsel oluşturma BAŞARISIZ")
                        visual_path = None

                except Exception as e:
                    print(f"!!! GÖRSELLEŞTİRME HATASI: {e}")
                    import traceback
                    print(f"!!! Traceback: {traceback.format_exc()}")
                    visual_stop = None

            total_item_volume = sum(item.get_volume() for item in packed_bin_3d.items)
            utilization = round((total_item_volume / packed_bin_3d.get_volume()) * 100, 2)
            total_weight = sum(item.weight for item in packed_bin_3d.items)

            packed_bins_response.append(PackedBin(
                bin_id=packed_bin_3d.name,
                items=current_packed_items, # Düzeltme: current_packed_items
                utilization_percent=utilization,
                weight_used=total_weight,
                visual_path=visual_path # Burası artık tam GCS URL'si olmalı
            ))

            # Hafıza temizliği (Cloud Run için kritik)
            del packer
            gc.collect()

            # --- DÖNGÜ BİTTİ ---

        unpacked_items_response: List[str] = list(yerlestirilecek_idler)
        print(f"\n[Packer] TÜM HESAPLAMA TAMAMLANDI.")
        print(f"[Packer] Toplam {len(packed_bins_response)} araç kullanıldı.")
        print(f"[Packer] Yerleşemeyen toplam koli sayısı: {len(unpacked_items_response)}")

        return packed_bins_response, unpacked_items_response