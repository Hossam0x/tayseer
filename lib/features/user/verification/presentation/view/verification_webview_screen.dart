// ===============================
// verification_webview_screen.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:tayseer/my_import.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';

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
  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }
  // ─────────────────────────────────────────────
  // Handle callback URL from the identity provider
  // Pops with VerificationStatus so caller knows
  // to re-fetch from the API.
  // ─────────────────────────────────────────────
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
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url =
                  navigationAction.request.url?.toString() ?? '';

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
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}