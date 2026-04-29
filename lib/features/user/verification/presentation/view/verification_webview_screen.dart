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

class _VerificationWebViewScreenState extends State<VerificationWebViewScreen> {
  bool _isLoading = true;
  bool _permissionsGranted = false;
  bool _permissionsPermanentlyDenied = false;

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      setState(() {
        _permissionsGranted = false;
        _permissionsPermanentlyDenied = true;
      });
      return;
    }

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
      _permissionsGranted = finalCamera.isGranted && finalMic.isGranted;
      _permissionsPermanentlyDenied = false;
    });
  }

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

  Widget _buildPermissionDeniedScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            context.tr('camera_access_required'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('camera_access_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              await _requestPermissions();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFFD375F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.tr('open_settings'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr('go_back'),
              style: const TextStyle(color: Colors.grey),
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
        title: Text(context.tr('verification_title')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _permissionsPermanentlyDenied
          ? _buildPermissionDeniedScreen()
          : !_permissionsGranted
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.webviewUrl)),
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
                  onPermissionRequest: (controller, request) async {
                    final cameraStatus = await Permission.camera.status;
                    final micStatus = await Permission.microphone.status;

                    if (cameraStatus.isGranted && micStatus.isGranted) {
                      return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT,
                      );
                    } else {
                      await Permission.camera.request();
                      await Permission.microphone.request();

                      final newCamera = await Permission.camera.status;
                      if (newCamera.isGranted) {
                        return PermissionResponse(
                          resources: request.resources,
                          action: PermissionResponseAction.GRANT,
                        );
                      }
                      return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.DENY,
                      );
                    }
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
                  onLoadStop: (_, __) => setState(() => _isLoading = false),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
