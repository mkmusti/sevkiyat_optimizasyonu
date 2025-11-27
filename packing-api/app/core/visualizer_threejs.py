# app/core/visualizer_threejs.py
import os
from py3dbp import Bin
from google.cloud import storage
import traceback

GCS_BUCKET_NAME = 'sevkiyat-optimizasyon-api-sevkiyat-gorselleri'

class ThreeJSVisualizer:
    # Bu sınıf artık kalıcı GCS bağlantılarını tutmaz.

    def __init__(self):
        self.colors = [
            '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A',
            '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2'
        ]

    def create_3d_visualization(self, bin_obj: Bin, output_path: str) -> str:
        """Three.js ile interaktif 3D HTML oluştur ve GCS'ye yükle"""
        print(f"[ThreeJS-Visualizer] Başlıyor: {bin_obj.name}")

        # --- DÜZELTME: GCS İstemcisini HER ÇAĞRIDA SIFIRDAN BAŞLAT ---
        try:
            # KRİTİK: Her seferinde başlat, çünkü Cloud Run hafızasına güvenmiyoruz.
            storage_client = storage.Client()
            bucket = storage_client.bucket(GCS_BUCKET_NAME)
            print("[GCS_CONN] Bağlantı başarılı (Anlık).")
        except Exception as e:
            # Uygulamanın çökmesini önlemek için, sadece bu çağrıyı başarısız sayarız.
            print(f"[GCS_CONN] ❌ KRİTİK BAĞLANTI HATASI: GCS istemcisi başlatılamadı: {e}")
            return None
        # --- Bağlantı Bitti ---

        try:
            file_name = os.path.basename(output_path)

            if not bin_obj.items:
                print(f"[ThreeJS-Visualizer] UYARI: {bin_obj.name} boş!")
                return None

            # EKSEN DÜZELTME VERİSİ
            bin_data = {
                'width': float(bin_obj.width),
                'height': float(bin_obj.height),
                'depth': float(bin_obj.depth)
            }
            items_data = []

            for i, item in enumerate(bin_obj.items):
                x, z_pos, y_pos = [float(p) for p in item.position]
                w, l_dim, h_dim = [float(dim) for dim in item.get_dimension()]

                items_data.append({
                    'name': item.name,
                    # Three.js Pozisyonu (X, Y, Z) (Merkez noktası)
                    'position': [x + w/2, y_pos + h_dim/2, z_pos + l_dim/2],
                    # Three.js Boyutları (W, H, L)
                    'dimensions': [w, h_dim, l_dim],
                    'color': self.colors[i % len(self.colors)]
                })

            utilization = self._calculate_utilization(bin_obj)

            # HTML içeriğini oluştur
            html_content = self._generate_html(bin_data, items_data, bin_obj.name, utilization)

            # --- YÜKLEME ---
            print(f"[ThreeJS-Visualizer] {file_name} GCS'ye yükleniyor...")

            # Yeni oluşturulan bucket nesnesini kullan
            blob = bucket.blob(file_name)

            blob.upload_from_string(
                html_content,
                content_type='text/html; charset=utf-8'
            )

            public_url = blob.public_url

            print(f"[ThreeJS-Visualizer] ✅ BAŞARILI: {public_url}")
            return public_url

        except Exception as e:
            print(f"[ThreeJS-Visualizer] ❌ HATA: Görsel oluşturma/yükleme sırasında hata: {e}")
            traceback.print_exc()
            return None

    # --- YARDIMCI METODLAR (TAM İÇERİK) ---

    def _calculate_utilization(self, bin_obj):
        """Doluluk oranını hesapla"""
        try:
            total_volume = sum(float(item.get_volume()) for item in bin_obj.items)
            bin_volume = float(bin_obj.get_volume())
            return (total_volume / bin_volume) * 100 if bin_volume > 0 else 0
        except:
            return 0

    def _generate_legend_html(self, items_data):
        """Legend HTML'i oluştur"""
        legend_html = ""
        for item in items_data:
            legend_html += f'''
        <div class="legend-item">
            <div class="legend-color" style="background-color: {item['color']};"></div>
            <span>{item['name']}</span>
        </div>'''
        return legend_html


    def _generate_html(self, bin_data, items_data, bin_name, utilization):
        """Three.js HTML template'i oluştur"""

        # WxYxU gösterimi için eksenleri ayarla (W, H, L)
        display_w = bin_data['width']
        display_h = bin_data['depth']
        display_l = bin_data['height']

        return f'''<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{bin_name} - 3D Yükleme Planı</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow: hidden;
            background: linear-gradient(135deg, #2b2b2b 0%, #1a1a1a 100%);
        }}
        #container {{
            width: 100vw;
            height: 100vh;
            position: relative;
        }}
        #info {{
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            font-size: 14px;
            backdrop-filter: blur(10px);
            z-index: 10;
        }}
        #info h2 {{
            margin: 0 0 10px 0;
            font-size: 18px;
            color: #4ECDC4;
        }}
        #controls {{
            position: absolute;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0,0,0,0.7);
            padding: 15px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            z-index: 10;
        }}
        .control-btn {{
            background: #4ECDC4;
            border: none;
            color: white;
            padding: 10px 20px;
            margin: 0 5px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
        }}
        .control-btn:hover {{
            background: #45B7D1;
            transform: translateY(-2px);
        }}
        #legend {{
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 15px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            max-height: 80vh;
            overflow-y: auto;
            z-index: 10;
        }}
        .legend-item {{
            display: flex;
            align-items: center;
            margin: 8px 0;
            font-size: 12px;
        }}
        .legend-color {{
            width: 20px;
            height: 20px;
            margin-right: 10px;
            border-radius: 3px;
            border: 1px solid white;
        }}
    </style>
</head>
<body>
    <div id="container"></div>
    
    <div id="info">
        <h2>🚚 {bin_name}</h2>
        <p><strong>Araç Boyutları:</strong> {display_w:.0f} × {display_h:.0f} × {display_l:.0f} cm (G×Y×U)</p>
        <p><strong>Yüklenen Koli:</strong> {len(items_data)} adet</p>
        <p><strong>Doluluk:</strong> {utilization:.1f}%</p>
    </div>
    
    <div id="controls">
        <button class="control-btn" onclick="resetCamera()">🎯 Sıfırla</button>
        <button class="control-btn" onclick="toggleWireframe()">📦 Wireframe</button>
        <button class="control-btn" onclick="toggleRotation()">🔄 Oto-Döndür</button>
    </div>
    
    <div id="legend">
        <h3 style="margin-bottom: 10px;">📦 Koliler</h3>
        {self._generate_legend_html(items_data)}
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        // Three.js Kurulum
        const scene = new THREE.Scene();
        scene.background = new THREE.Color(0x1a1a2e);
        
        const camera = new THREE.PerspectiveCamera(
            60,
            window.innerWidth / window.innerHeight,
            0.1,
            10000
        );
        
        const renderer = new THREE.WebGLRenderer({{ antialias: true }});
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.shadowMap.enabled = true;
        document.getElementById('container').appendChild(renderer.domElement);
        
        // Işıklar
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
        scene.add(ambientLight);
        
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(100, 200, 100);
        directionalLight.castShadow = true;
        scene.add(directionalLight);
        
        // Eksen Düzeltmeli Veri
        const binW = {bin_data['width']};
        const binL = {bin_data['height']};
        const binH = {bin_data['depth']};
        
        // Araç (Bin) - Wireframe - Three.js (W, H, L)
        const binGeometry = new THREE.BoxGeometry(binW, binH, binL);
        const binEdges = new THREE.EdgesGeometry(binGeometry);
        const binLine = new THREE.LineSegments(
            binEdges,
            new THREE.LineBasicMaterial({{ color: 0xffffff, linewidth: 2 }})
        );
        binLine.position.set(binW/2, binH/2, binL/2);
        scene.add(binLine);
        
        // Koliler
        const items = {items_data};
        let wireframeMode = false;
        const itemMeshes = [];
        
        items.forEach((item, index) => {{
            const geometry = new THREE.BoxGeometry(
                item.dimensions[0], // W
                item.dimensions[1], // H
                item.dimensions[2]  // L
            );
            
            const material = new THREE.MeshPhongMaterial({{
                color: item.color,
                transparent: true,
                opacity: 0.8,
                shininess: 30
            }});
            
            const mesh = new THREE.Mesh(geometry, material);
            
            mesh.position.set(
                item.position[0], // X
                item.position[1], // Y
                item.position[2]  // Z
            );
            mesh.castShadow = true;
            mesh.receiveShadow = true;
            
            scene.add(mesh);
            itemMeshes.push(mesh);
            
            const edges = new THREE.EdgesGeometry(geometry);
            const line = new THREE.LineSegments(
                edges,
                new THREE.LineBasicMaterial({{ color: 0x000000, linewidth: 1 }})
            );
            mesh.add(line);
        }});
        
        // Kamera pozisyonu
        const maxDim = Math.max(binW, binH, binL);
        const rotationCenter = new THREE.Vector3(binW/2, binH/2, binL/2);
        camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.5);
        camera.lookAt(rotationCenter);
        
        // Mouse kontrolü
        let isDragging = false;
        let previousMousePosition = {{ x: 0, y: 0 }};
        let autoRotate = false;
        
        // --- HAREKET VE DÖNDÜRME MANTIĞI ---
        function handleRotation(deltaMoveX, deltaMoveY) {{
            const deltaRotationQuaternion = new THREE.Quaternion()
                .setFromEuler(new THREE.Euler(
                    deltaMoveY * 0.01,
                    deltaMoveX * 0.01,
                    0,
                    'XYZ'
                ));
            
            camera.position.sub(rotationCenter);
            camera.position.applyQuaternion(deltaRotationQuaternion);
            camera.position.add(rotationCenter);

            camera.lookAt(rotationCenter);
        }}

        // MASAÜSTÜ OLAYLARI
        renderer.domElement.addEventListener('mousedown', (e) => {{
            isDragging = true;
        }});
        
        renderer.domElement.addEventListener('mousemove', (e) => {{
            if (isDragging) {{
                const deltaMove = {{
                    x: e.offsetX - previousMousePosition.x,
                    y: e.offsetY - previousMousePosition.y
                }};
                handleRotation(deltaMove.x, deltaMove.y);
            }}
            
            previousMousePosition = {{
                x: e.offsetX,
                y: e.offsetY
            }};
        }});
        
        renderer.domElement.addEventListener('mouseup', () => {{
            isDragging = false;
        }});
        
        // MOBİL DOKUNMATİK OLAYLARI (TOUCH EVENTS)
        renderer.domElement.addEventListener('touchstart', (e) => {{
            isDragging = true;
            if (e.touches.length === 1) {{
                 previousMousePosition = {{
                    x: e.touches[0].clientX,
                    y: e.touches[0].clientY
                }};
            }}
        }});

        renderer.domElement.addEventListener('touchmove', (e) => {{
            e.preventDefault(); // Varsayılan kaydırma davranışını engelle
            if (isDragging && e.touches.length === 1) {{
                const deltaMove = {{
                    x: e.touches[0].clientX - previousMousePosition.x,
                    y: e.touches[0].clientY - previousMousePosition.y
                }};
                handleRotation(deltaMove.x, deltaMove.y);
            }}
            
            previousMousePosition = {{
                x: e.touches[0].clientX,
                y: e.touches[0].clientY
            }};
        }});
        
        renderer.domElement.addEventListener('touchend', () => {{
            isDragging = false;
        }});
        
        // Zoom (Mouse wheel)
        renderer.domElement.addEventListener('wheel', (e) => {{
            e.preventDefault();
            const zoomSpeed = 50;
            const direction = new THREE.Vector3();
            camera.getWorldDirection(direction);
            
            if (e.deltaY < 0) {{
                camera.position.add(direction.multiplyScalar(zoomSpeed));
            }} else {{
                camera.position.sub(direction.multiplyScalar(zoomSpeed));
            }}
        }});
        
        // Kontrol fonksiyonları
        window.resetCamera = function() {{
            camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.5);
            camera.lookAt(rotationCenter);
        }}
        
        window.toggleWireframe = function() {{
            wireframeMode = !wireframeMode;
            itemMeshes.forEach(mesh => {{
                mesh.material.wireframe = wireframeMode;
            }});
        }}
        
        window.toggleRotation = function() {{
            autoRotate = !autoRotate;
        }}
        
        // Animasyon döngüsü
        function animate() {{
            requestAnimationFrame(animate);
            
            if (autoRotate) {{
                camera.position.applyAxisAngle(new THREE.Vector3(0, 1, 0), 0.005);
                camera.lookAt(rotationCenter);
            }}
            
            renderer.render(scene, camera);
        }}
        
        animate();
        
        // Responsive
        window.addEventListener('resize', () => {{
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }});
    </script>
</body>
</html>'''

# Alias
Visualization3D = ThreeJSVisualizer