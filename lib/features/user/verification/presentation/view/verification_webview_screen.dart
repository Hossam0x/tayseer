import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
// Note: Ensure your 'my_import.dart' or specific imports for VerificationStatus are correct
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
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  /// Requests system-level permissions for Camera and Mic
  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  /// Handles logic when the identity provider redirects to a callback URL
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification"), // Optional: adds context to the header
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.webviewUrl),
            ),
            initialSettings: InAppWebViewSettings(
              // Essential for video/camera functionality
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              // Better compatibility for some verification APIs
              javaScriptEnabled: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            // CRITICAL: This grants the website permission within the WebView
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';

              if (url.contains('callback')) {
                _handleCallbackUrl(url);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStart: (_, __) => setState(() => _isLoading = true),
            onLoadStop: (_, __) => setState(() => _isLoading = false),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}