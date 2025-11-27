# check_environment.py
import sys
import importlib.util
import os
import platform

def check_python_version():
    """Python versiyonunu kontrol et"""
    version = sys.version_info
    print(f"🐍 Python {version.major}.{version.minor}.{version.micro}")
    return version.major >= 3 and version.minor >= 8

def check_python_deps():
    """Python bağımlılıklarını kontrol et"""
    required = ['flask', 'flask_cors', 'py3dbp', 'matplotlib', 'numpy', 'pillow']
    missing = []
    
    print("\n📦 Python Bağımlılıkları Kontrolü:")
    for package in required:
        try:
            if importlib.util.find_spec(package) is not None:
                print(f"   ✅ {package}")
            else:
                print(f"   ❌ {package}")
                missing.append(package)
        except:
            print(f"   ❌ {package}")
            missing.append(package)
    
    return missing

def check_webview2():
    """WebView2 runtime kontrolü"""
    try:
        import ctypes
        # WebView2Loader.dll kontrolü
        if hasattr(ctypes, 'windll'):
            try:
                ctypes.windll.WebView2Loader
                print("   ✅ WebView2 Runtime mevcut")
                return True
            except:
                print("   ❌ WebView2 Runtime yüklü değil")
                return False
    except:
        print("   ❌ WebView2 kontrolü başarısız")
        return False

def check_directories():
    """Gerekli dizinleri kontrol et - packing-api kullan"""
    required_dirs = ['packing-api', 'packing-api/app', 'packing-api/app/outputs']
    missing_dirs = []
    
    print("\n📁 Dizin Kontrolü:")
    for dir_path in required_dirs:
        if os.path.exists(dir_path):
            print(f"   ✅ {dir_path}")
        else:
            print(f"   ❌ {dir_path}")
            missing_dirs.append(dir_path)
    
    return missing_dirs

def main():
    print("🔍 Sevkiyat Optimizasyonu - Ortam Kontrolü")
    print("=" * 50)
    
    all_ok = True
    
    # Python versiyonu
    if not check_python_version():
        print("❌ Python 3.8 veya üstü gerekli")
        all_ok = False
    
    # Python bağımlılıkları
    missing_deps = check_python_deps()
    if missing_deps:
        print(f"❌ Eksik bağımlılıklar: {', '.join(missing_deps)}")
        all_ok = False
    
    # WebView2
    if not check_webview2():
        print("❌ WebView2 Runtime gerekli")
        all_ok = False
    
    # Dizinler - packing-api kullan
    missing_dirs = check_directories()
    if missing_dirs:
        print(f"❌ Eksik dizinler: {', '.join(missing_dirs)}")
        all_ok = False
    
    print("\n" + "=" * 50)
    if all_ok:
        print("🎉 Tüm kontroller başarılı! Uygulama çalıştırılabilir.")
        return 0
    else:
        print("⚠️  Bazı sorunlar tespit edildi. Lütfen yukarıdaki hataları düzeltin.")
        return 1

if __name__ == "__main__":
    sys.exit(main())