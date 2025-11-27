// lib/bin_packing_3d_viewer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart' as webview_windows;
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;
import 'dart:io';
import 'package:http/http.dart' as http;

class BinPacking3DViewer extends StatefulWidget {
  final String? visualPath;
  const BinPacking3DViewer({
    super.key,
    this.visualPath,
  });

  @override
  State<BinPacking3DViewer> createState() => _BinPacking3DViewerState();
}

class _BinPacking3DViewerState extends State<BinPacking3DViewer> {
  Object? _controller;
  String? _fullUrl;
  bool _isLoading = true;
  String _status = "3D Görsel kontrol ediliyor...";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkAndInitializeViewer();
  }

  Future<void> _checkAndInitializeViewer() async {
    try {
      _fullUrl = _getFullUrl();
      if (_fullUrl == null) {
        _setErrorState('HATA: Görsel yolu (visualPath) boş.');
        return;
      }
      setState(() {
        _status = "Sunucu kontrol ediliyor...";
      });
      final bool isAvailable = await _checkVisualAvailability();
      if (!isAvailable) {
        _setErrorState('3D görsel henüz oluşturulmamış.\n\n'
            'Bu genellikle şu nedenlerle olur:\n'
            '• Optimizasyon henüz tamamlanmamış\n'
            '• Sunucu görseli işlerken hata aldı\n'
            '• İnternet bağlantısı problemi\n\n'
            'Lütfen biraz bekleyip tekrar deneyin veya\n'
            'optimizasyonu yeniden başlatın.');
        return;
      }
      await _initializeWebView();
    } catch (e) {
      _setErrorState("Bağlantı hatası: $e");
    }
  }

  Future<bool> _checkVisualAvailability() async {
    try {
      final response = await http.get(
        Uri.parse(_fullUrl!),
        headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
      );
      // print('🔍 URL Kontrol: $_fullUrl');
      return response.statusCode == 200 && response.body.isNotEmpty;
    } catch (e) {
      // print('❌ Availability check error: $e');
      return false;
    }
  }

  // ⭐ YENİ: HTML içeriğine zoom'u etkinleştiren script enjekte et
  void _injectZoomScript(webview_flutter.WebViewController controller) {
    controller.runJavaScript('''
      // Viewport meta tag'ini kontrol et ve güncelle
      function ensureZoomable() {
        var viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
          var content = viewport.getAttribute('content');
          if (!content.includes('user-scalable=yes') && !content.includes('user-scalable=1')) {
            viewport.setAttribute('content', content + ', user-scalable=yes');
          }
          if (!content.includes('maximum-scale')) {
            viewport.setAttribute('content', content + ', maximum-scale=5.0');
          }
        } else {
          // Viewport yoksa oluştur
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        
        // Touch event'lerini engelleyen CSS'leri kaldır
        var style = document.createElement('style');
        style.innerHTML = 'body { -webkit-user-select: none; -webkit-touch-callout: none; } * { -webkit-tap-highlight-color: transparent; }';
        document.head.appendChild(style);
      }
      
      // Sayfa yüklendikten sonra ve her 2 saniyede bir kontrol et
      ensureZoomable();
      setInterval(ensureZoomable, 2000);
    ''');
  }

  Future<void> _initializeWebView() async {
    try {
      setState(() {
        _status = "3D Görünüm yükleniyor...";
      });
      if (Platform.isWindows) {
        // WINDOWS İÇİN KOD (DEĞİŞMEDİ)
        final windowsController = webview_windows.WebviewController();
        await windowsController.initialize();

        final theme = Theme.of(context);
        await windowsController.setBackgroundColor(theme.scaffoldBackgroundColor);

        // print('🌐 Windows WebView loading URL: $_fullUrl');
        await windowsController.loadUrl(_fullUrl!);
        _controller = windowsController;
      } else {
        // ⭐ GÜNCELLENMİŞ MOBİL WEBVIEW AYARLARI
        final mobileController = webview_flutter.WebViewController();

        // WebView ayarlarını ayrı ayrı set et
        mobileController.setJavaScriptMode(webview_flutter.JavaScriptMode.unrestricted);
        mobileController.enableZoom(true); // Zoom özelliği aktif
        mobileController.setBackgroundColor(const Color(0x00000000));

        // Navigation delegate'i ayarla
        mobileController.setNavigationDelegate(
          webview_flutter.NavigationDelegate(
            onPageFinished: (String url) {
              // ⭐ YENİ: Sayfa yüklendikten sonra zoom script'i enjekte et
              _injectZoomScript(mobileController);
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _status = "3D Görünüm hazır!";
                });
              }
            },
            onWebResourceError: (error) {
              // print('❌ Mobile WebView Error: ${error.description}');
              _setErrorState("Web içeriği yüklenemedi: ${error.description}");
            },
          ),
        );

        // URL'yi yükle
        mobileController.loadRequest(Uri.parse(_fullUrl!));

        _controller = mobileController;
        // print('🌐 Mobile WebView loading URL: $_fullUrl');
      }

      if (mounted && Platform.isWindows) {
        setState(() {
          _isLoading = false;
          _status = "3D Görünüm hazır!";
        });
      }

      Timer(const Duration(seconds: 8), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _status = "Yükleme zaman aşımına uğradı. Sayfayı yenilemeyi deneyin.";
          });
        }
      });
    } catch (e) {
      // print('❌ WebView initialization error: $e');
      _setErrorState("WebView başlatılamadı: $e");
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _status = message;
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String? _getFullUrl() {
    if (widget.visualPath == null || widget.visualPath!.isEmpty) {
      return null;
    }
    if (widget.visualPath!.startsWith('http')) {
      return widget.visualPath;
    }
    String htmlPath = widget.visualPath!.replaceAll('.png', '.html').replaceAll('.jpg', '.html').replaceAll('.jpeg', '.html');
    String baseUrl = 'https://sevkiyat-api-547787121667.europe-west1.run.app';
    if (!baseUrl.endsWith('/') && !htmlPath.startsWith('/')) {
      baseUrl += '/';
    } else if (baseUrl.endsWith('/') && htmlPath.startsWith('/')) {
      htmlPath = htmlPath.substring(1);
    }
    String fullUrl = '$baseUrl$htmlPath';
    return fullUrl;
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _status = "Tekrar deneniyor...";
    });
    if (Platform.isWindows && _controller is webview_windows.WebviewController) {
      (_controller as webview_windows.WebviewController).dispose();
      _controller = null;
    }
    _checkAndInitializeViewer();
  }

  @override
  void dispose() {
    if (Platform.isWindows && _controller is webview_windows.WebviewController) {
      (_controller as webview_windows.WebviewController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Kapat',
        ),
        title: const Text('🚢 3D İnteraktif Görünüm'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (_hasError || !_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retry,
              tooltip: 'Yeniden Dene',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return _buildWebView();
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 20),
          Text(
            _status,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Lütfen bekleyin...",
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              "3D Görsel Yüklenemedi",
              style: TextStyle(
                color: theme.textTheme.displaySmall?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _status,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "URL: ${_fullUrl ?? 'Belirtilmemiş'}",
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Detaylı Kontrol'),
                  onPressed: _showDebugInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Kapat'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    if (_controller == null) {
      return _buildErrorState();
    }

    final successMessage = Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green[900],
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              Platform.isWindows
                  ? "3D Görünüm başarıyla yüklendi. Modeli fare ile döndürebilir, yakınlaştırabilirsiniz."
                  : "3D Görünüm başarıyla yüklendi. Modeli parmağınızla döndürebilir, sıkıştırıp açarak yakınlaştırabilirsiniz.",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
    if (Platform.isWindows) {
      return Column(
        children: [
          successMessage,
          Expanded(
            child: webview_windows.Webview(_controller! as webview_windows.WebviewController),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          successMessage,
          Expanded(
            child: webview_flutter.WebViewWidget(controller: _controller! as webview_flutter.WebViewController),
          ),
        ],
      );
    }
  }

  void _showDebugInfo() {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : theme.scaffoldBackgroundColor,
        title: Text('Hata Ayıklama Bilgisi', style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Visual Path:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              Text('${widget.visualPath}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 12),
              Text('Full URL:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              Text('$_fullUrl', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 12),
              Text('Base URL:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              Text('https://sevkiyat-api-547787121667.europe-west1.run.app',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 16),
              Divider(color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'WebView Ayarları:',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• JavaScript: AKTİF', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              Text('• Zoom: AKTİF', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              Text('• Viewport Injection: AKTİF', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              Text('• Pinch-to-Zoom: DESTEKLENİYOR', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Kapat', style: TextStyle(color: theme.primaryColor)),
          ),
        ],
      ),
    );
  }
}
