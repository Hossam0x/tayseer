import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/verification_page.dart';
import 'package:tayseer/my_import.dart';

class VerificationWebViewScreen extends StatefulWidget {
  final String webviewUrl;
  final Function(bool isValid) onVerificationComplete;

  const VerificationWebViewScreen({
    super.key,
    required this.webviewUrl,
    required this.onVerificationComplete,
  });

  @override
  State<VerificationWebViewScreen> createState() =>
      _VerificationWebViewScreenState();
}

class _VerificationWebViewScreenState extends State<VerificationWebViewScreen> {
  bool _isLoading = true;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  void _handleVerificationStatus(String status) {
    if (!mounted) return;

    if (status == 'Approved') {
      Navigator.pop(context, VerificationStatus.approved);
    } else if (status == 'In Review') {
      Navigator.pop(context, VerificationStatus.inReview);
    } else {
      Navigator.pop(context, VerificationStatus.rejected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          context.tr('verify'),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.webviewUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useOnLoadResource: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              useHybridComposition: true,
              cacheEnabled: true,
              allowsPictureInPictureMediaPlayback: true,
            ),

            // ✅ اعتراض الـ URL قبل فتحه
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';

              if (url.contains('tayser-app.net/didit/callback')) {
                final uri = Uri.parse(url);
                final status = uri.queryParameters['status'] ?? '';

                _handleVerificationStatus(status);

                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },

            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },

            androidOnGeolocationPermissionsShowPrompt:
                (controller, origin) async {
                  return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true,
                    retain: true,
                  );
                },

            onWebViewCreated: (controller) {
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'userVerificationStatus',
                callback: (args) {
                  try {
                    final data = args.isNotEmpty ? args[0] : null;

                    if (data is Map && data['valid'] == true) {
                      Navigator.pop(context, VerificationStatus.approved);
                    } else {
                      Navigator.pop(context, VerificationStatus.rejected);
                    }
                  } catch (_) {
                    Navigator.pop(context, VerificationStatus.rejected);
                  }
                },
              );
            },

            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },

            onLoadStop: (controller, url) async {
              if (mounted) setState(() => _isLoading = false);

              await controller.evaluateJavascript(
                source: '''
                (function() {
                  window.addEventListener('message', function(event) {
                    try {
                      var data = event.data;
                      if (typeof data === 'string') {
                        data = JSON.parse(data);
                      }
                      if (data && data.valid !== undefined) {
                        window.flutter_inappwebview.callHandler(
                          'userVerificationStatus', data
                        );
                      }
                    } catch(e) {}
                  });

                  var _verStatus;
                  Object.defineProperty(window, 'userVerificationStatus', {
                    get: function() { return _verStatus; },
                    set: function(value) {
                      _verStatus = value;
                      try {
                        window.flutter_inappwebview.callHandler(
                          'userVerificationStatus', value
                        );
                      } catch(e) {}
                    },
                    configurable: true
                  });

                  window.addEventListener('didit:session:complete', function(event) {
                    try {
                      var detail = event.detail || {};
                      window.flutter_inappwebview.callHandler(
                        'userVerificationStatus',
                        { valid: detail.status === 'Approved' || detail.valid === true }
                      );
                    } catch(e) {}
                  });
                })();
              ''',
              );
            },

            onReceivedError: (controller, request, error) {
              if (mounted) setState(() => _isLoading = false);
            },

            onReceivedHttpError: (controller, request, errorResponse) {
              debugPrint(
                '⚠️ HTTP error: ${errorResponse.statusCode} for ${request.url}',
              );
            },
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VerificationService
// ─────────────────────────────────────────────

class VerificationService {
  static Future<String?> getVerificationUrl() async {
    try {
      final apiService = getIt<ApiService>();

      final response = await apiService.get(endPoint: '/user/verify-id-didit');

      if (response['success'] == true) {
        return response['data']['webview'] as String?;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return null;
    }
  }
}
