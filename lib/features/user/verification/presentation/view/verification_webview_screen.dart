import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
import 'package:tayseer/my_import.dart';

class VerificationWebViewScreen extends StatefulWidget {
  final String webviewUrl;

  const VerificationWebViewScreen({super.key, required this.webviewUrl});

  @override
  State<VerificationWebViewScreen> createState() =>
      _VerificationWebViewScreenState();
}

class _VerificationWebViewScreenState
    extends State<VerificationWebViewScreen> {
  bool _isLoading = true;

  // ✅ FIX: منفصلين عشان نعرف نعرض رسالة لو الأذونات اترفضت
  bool _permissionsGranted = false;
  bool _permissionsPermanentlyDenied = false;

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ FIX: طلب الأذونات بشكل صحيح مع التعامل مع حالة الرفض الدائم
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    // ✅ تحقق من الـ status الحالي أول
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;

    // لو مش granted، اطلبهم
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    // ✅ انتظر عشان الـ system يسجل الـ grant
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      setState(() {
        _permissionsGranted = false;
        _permissionsPermanentlyDenied = true;
      });
      return;
    }

    // ✅ تحقق مرة تانية بعد الـ delay
    final finalCamera = await Permission.camera.status;
    final finalMic = await Permission.microphone.status;

    if (!mounted) return;

    if (finalCamera.isPermanentlyDenied || finalMic.isPermanentlyDenied) {
      setState(() {
        _permissionsGranted = false;
        _permissionsPermanentlyDenied = true;
      });
      return;
    }

    setState(() {
      _permissionsGranted = true;
      _permissionsPermanentlyDenied = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Callback URL handler — unchanged logic
  // ─────────────────────────────────────────────────────────────────────────
  void _handleCallbackUrl(String url) {
    if (!mounted) return;

    final uri = Uri.parse(url);
    final status = uri.queryParameters['status'] ?? '';

    if (status == 'Approved') {
      Navigator.pop(context, VerificationStatus.approved);
    } else {
      Navigator.pop(context, VerificationStatus.rejected);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ FIX: شاشة بديلة لما الأذونات ترفض نهائياً
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPermissionDeniedScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'الوصول إلى الكاميرا مطلوب',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'يرجى السماح بالوصول إلى الكاميرا من إعدادات الهاتف لإكمال عملية التحقق.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              // بعد ما يرجع من الإعدادات، نعيد المحاولة
              await _requestPermissions();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFFD375F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'فتح الإعدادات',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'رجوع',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التحقق"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _permissionsPermanentlyDenied
          // ✅ لو اترفض نهائياً، اعرض شاشة توضيحية
          ? _buildPermissionDeniedScreen()
          : !_permissionsGranted
              // لو لسه بيطلب الأذونات
              ? const Center(child: CircularProgressIndicator())
              // ✅ الأذونات اتأخدت، اعرض الـ WebView
              : Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(widget.webviewUrl),
                      ),
                      initialSettings: InAppWebViewSettings(
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        useHybridComposition: true,
                        allowFileAccessFromFileURLs: true,
                        allowUniversalAccessFromFileURLs: true,
                        disableDefaultErrorPage: true,
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      // ✅ FIX: منح الأذونات للموقع داخل الـ WebView
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                          resources: request.resources,
                          action: PermissionResponseAction.GRANT,
                        );
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        final url =
                            navigationAction.request.url?.toString() ?? '';

                        if (url.contains('callback')) {
                          _handleCallbackUrl(url);
                          return NavigationActionPolicy.CANCEL;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      // ✅ لما الكاميرا تفشل في الـ WebView، اعرض شاشة الإعدادات
                      onConsoleMessage: (controller, message) async {
                        if (message.message.contains('Error getting user media') ||
                            message.message.contains('cannot open camera')) {
                          if (mounted) {
                            setState(() {
                              _permissionsPermanentlyDenied = true;
                              _permissionsGranted = false;
                            });
                          }
                        }
                      },
                      onLoadStop: (_, __) =>
                          setState(() => _isLoading = false),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }
}