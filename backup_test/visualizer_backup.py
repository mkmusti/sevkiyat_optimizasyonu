# app/core/visualizer.py
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import os
from typing import List
from py3dbp import Bin, Item

class Visualization3D:
    def __init__(self):
        self.colors = ['red', 'green', 'blue', 'yellow', 'orange', 'purple', 
                      'cyan', 'magenta', 'brown', 'pink', 'gray', 'olive']
    
    def create_3d_visualization(self, bin_obj: Bin, output_path: str) -> str:
        """
        Geliştirilmiş 3D görselleştirme - Hata düzeltmeli
        """
        try:
            print(f"[Visualizer] Görsel oluşturuluyor: {output_path}")
            
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            w = float(bin_obj.width)
            h = float(bin_obj.height) 
            d = float(bin_obj.depth)
            
            fig = plt.figure(figsize=(12, 9))
            ax = fig.add_subplot(111, projection='3d')
            
            # 1. Araç çerçevesini çiz
            self._draw_bin_frame(ax, w, h, d)
            
            # 2. Kolileri çiz (hata yönetimli)
            if bin_obj.items:
                successful_items = 0
                for i, item in enumerate(bin_obj.items):
                    color = self.colors[i % len(self.colors)]
                    if self._draw_item_safe(ax, item, color, i):
                        successful_items += 1
                
                print(f"[Visualizer] Başarıyla çizilen koli: {successful_items}/{len(bin_obj.items)}")
            
            # 3. Grafik ayarları
            ax.set_xlabel('Genişlik (X)', fontweight='bold', fontsize=12)
            ax.set_ylabel('Derinlik (Y)', fontweight='bold', fontsize=12) 
            ax.set_zlabel('Yükseklik (Z)', fontweight='bold', fontsize=12)
            
            ax.set_xlim(0, w * 1.1)
            ax.set_ylim(0, d * 1.1)
            ax.set_zlim(0, h * 1.1)
            
            utilization = self._calculate_utilization(bin_obj)
            ax.set_title(f'Araç: {bin_obj.name}\nKullanım: {utilization:.1f}%', 
                        fontsize=14, fontweight='bold', pad=20)
            
            ax.grid(True, alpha=0.3)
            ax.view_init(elev=20, azim=45)
            
            plt.tight_layout()
            plt.savefig(output_path, dpi=120, bbox_inches='tight')
            plt.close()
            
            print(f"[Visualizer] BAŞARILI: Görsel kaydedildi: {output_path}")
            return output_path
            
        except Exception as e:
            print(f"[Visualizer] HATA: {str(e)}")
            import traceback
            print(f"[Visualizer] Traceback: {traceback.format_exc()}")
            return None
    
    def _draw_bin_frame(self, ax, width, height, depth):
        """Araç çerçevesini çiz"""
        vertices = np.array([
            [0, 0, 0], [width, 0, 0], [width, depth, 0], [0, depth, 0],
            [0, 0, height], [width, 0, height], [width, depth, height], [0, depth, height]
        ])
        edges = [
            [0,1], [1,2], [2,3], [3,0], [4,5], [5,6], [6,7], [7,4],
            [0,4], [1,5], [2,6], [3,7]
        ]
        for edge in edges:
            points = vertices[edge]
            ax.plot(points[:, 0], points[:, 1], points[:, 2], 'k--', alpha=0.5, linewidth=1)
    
    def _draw_item_safe(self, ax, item, color, index):
        """
        Güvenli koli çizimi - plot_trisurf yerine plot yöntemleri kullanır
        """
        try:
            x = float(item.position[0])
            y = float(item.position[1])  
            z = float(item.position[2])
            
            (w, h, d) = [float(dim) for dim in item.get_dimension()]
            
            # Minimum boyut kontrolü (çok küçük koliler için)
            min_size = 0.1
            w = max(w, min_size)
            h = max(h, min_size) 
            d = max(d, min_size)
            
            # Köşe noktaları
            vertices = np.array([
                [x, y, z], [x+w, y, z], [x+w, y+d, z], [x, y+d, z],
                [x, y, z+h], [x+w, y, z+h], [x+w, y+d, z+h], [x, y+d, z+h]
            ])
            
            # Yüzeyleri çizmek için geliştirilmiş yöntem
            self._draw_cube_faces(ax, vertices, color)
            
            # Koli numarası
            center_x = x + w/2
            center_y = y + d/2
            center_z = z + h/2
            
            ax.text(center_x, center_y, center_z, f'{index+1}', 
                   ha='center', va='center', fontsize=9, fontweight='bold',
                   bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.8))
            
            return True
                
        except Exception as e:
            print(f"[Visualizer] Koli {index} çizim hatası: {e}")
            return False
    
    def _draw_cube_faces(self, ax, vertices, color):
        """
        Küp yüzeylerini çiz - plot_trisurf alternatifi
        """
        # Yüzey tanımları
        faces = [
            [0,1,2,3],  # Alt
            [4,5,6,7],  # Üst  
            [0,1,5,4],  # Ön
            [2,3,7,6],  # Arka
            [1,2,6,5],  # Sağ
            [0,3,7,4]   # Sol
        ]
        
        for face in faces:
            try:
                # Yüzey köşe noktaları
                face_vertices = vertices[face]
                
                # Benzersiz nokta kontrolü
                unique_points = np.unique(face_vertices, axis=0)
                if len(unique_points) < 3:
                    # Yeterli nokta yoksa, basit çizgi çiz
                    x_vals = [vertices[i][0] for i in face + [face[0]]]  # Kapatmak için ilk noktayı tekrar ekle
                    y_vals = [vertices[i][1] for i in face + [face[0]]]
                    z_vals = [vertices[i][2] for i in face + [face[0]]]
                    ax.plot(x_vals, y_vals, z_vals, color=color, alpha=0.7, linewidth=2)
                else:
                    # Normal yüzey çizimi
                    x_vals = [vertices[i][0] for i in face]
                    y_vals = [vertices[i][1] for i in face] 
                    z_vals = [vertices[i][2] for i in face]
                    
                    # plot_trisurf yerine fill_between benzeri yaklaşım
                    from matplotlib.collections import PolyCollection
                    poly = PolyCollection([list(zip(x_vals, y_vals))], 
                                        alpha=0.7, facecolor=color, edgecolor='black')
                    ax.add_collection3d(poly, zs=z_vals, zdir='z')
                    
            except Exception as face_error:
                # Yüzey çizilemezse, en azından kenar çizgilerini çiz
                x_vals = [vertices[i][0] for i in face + [face[0]]]
                y_vals = [vertices[i][1] for i in face + [face[0]]]
                z_vals = [vertices[i][2] for i in face + [face[0]]]
                ax.plot(x_vals, y_vals, z_vals, color=color, alpha=0.5, linewidth=1)
    
    def _calculate_utilization(self, bin_obj: Bin) -> float:
        """Kullanım yüzdesini hesapla"""
        try:
            total_item_volume = sum(float(item.get_volume()) for item in bin_obj.items)
            bin_volume = float(bin_obj.get_volume())
            return (total_item_volume / bin_volume) * 100 if bin_volume > 0 else 0
        except:
            return 0.0