import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
    debugPrint('🌐 [VerificationWebViewScreen] initState() called');
    debugPrint(
      '🌐 [VerificationWebViewScreen] webviewUrl: ${widget.webviewUrl}',
    );
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    debugPrint(
      '🔐 [VerificationWebViewScreen] Requesting camera & microphone permissions...',
    );
    final statuses = await [Permission.camera, Permission.microphone].request();
    debugPrint('🔐 [VerificationWebViewScreen] Permission statuses: $statuses');
  }

  void _handleVerificationStatus(String status) {
    debugPrint(
      '🔔 [VerificationWebViewScreen] _handleVerificationStatus() called with status: "$status"',
    );

    if (!mounted) {
      debugPrint(
        '⚠️ [VerificationWebViewScreen] Widget not mounted, skipping navigation',
      );
      return;
    }

    if (status == 'Approved') {
      debugPrint(
        '✅ [VerificationWebViewScreen] Status Approved → popping with VerificationStatus.approved',
      );
      Navigator.pop(context, VerificationStatus.approved);
    } else if (status == 'In Review') {
      debugPrint(
        '⏳ [VerificationWebViewScreen] Status In Review → popping with VerificationStatus.inReview',
      );
      Navigator.pop(context, VerificationStatus.inReview);
    } else {
      debugPrint(
        '❌ [VerificationWebViewScreen] Status "$status" → popping with VerificationStatus.rejected',
      );
      Navigator.pop(context, VerificationStatus.rejected);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🌐 [VerificationWebViewScreen] build() called');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            debugPrint(
              '🌐 [VerificationWebViewScreen] Close button tapped → popping with false',
            );
            Navigator.pop(context, null);
          },
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

            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              debugPrint(
                '🔀 [VerificationWebViewScreen] shouldOverrideUrlLoading: $url',
              );

              if (url.contains('tayser-app.net/didit/callback')) {
                debugPrint(
                  '🎯 [VerificationWebViewScreen] Callback URL detected: $url',
                );
                final uri = Uri.parse(url);
                final status = uri.queryParameters['status'] ?? '';
                debugPrint(
                  '🎯 [VerificationWebViewScreen] Callback status param: "$status"',
                );

                _handleVerificationStatus(status);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },

            onPermissionRequest: (controller, request) async {
              debugPrint(
                '🔐 [VerificationWebViewScreen] onPermissionRequest: ${request.resources}',
              );
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },

            androidOnGeolocationPermissionsShowPrompt: (controller, origin) async {
              debugPrint(
                '📍 [VerificationWebViewScreen] Geolocation permission requested for: $origin',
              );
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },

            onWebViewCreated: (controller) {
              debugPrint(
                '🌐 [VerificationWebViewScreen] onWebViewCreated called',
              );
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'userVerificationStatus',
                callback: (args) {
                  debugPrint(
                    '📩 [VerificationWebViewScreen] JS handler "userVerificationStatus" called',
                  );
                  debugPrint(
                    '📩 [VerificationWebViewScreen] JS handler args: $args',
                  );

                  try {
                    final data = args.isNotEmpty ? args[0] : null;
                    debugPrint(
                      '📩 [VerificationWebViewScreen] JS handler data: $data',
                    );

                    if (data is Map && data['valid'] == true) {
                      debugPrint(
                        '✅ [VerificationWebViewScreen] JS handler: valid=true → approved',
                      );
                      Navigator.pop(context, VerificationStatus.approved);
                    } else {
                      debugPrint(
                        '❌ [VerificationWebViewScreen] JS handler: valid!=true → rejected',
                      );
                      Navigator.pop(context, VerificationStatus.rejected);
                    }
                  } catch (e) {
                    debugPrint(
                      '💥 [VerificationWebViewScreen] JS handler exception: $e → rejected',
                    );
                    Navigator.pop(context, VerificationStatus.rejected);
                  }
                },
              );
            },

            onLoadStart: (controller, url) {
              debugPrint('🔄 [VerificationWebViewScreen] onLoadStart: $url');
              if (mounted) setState(() => _isLoading = true);
            },

            onLoadStop: (controller, url) async {
              debugPrint('✅ [VerificationWebViewScreen] onLoadStop: $url');
              if (mounted) setState(() => _isLoading = false);

              debugPrint(
                '💉 [VerificationWebViewScreen] Injecting JS listeners...',
              );
              await controller.evaluateJavascript(
                source: '''
                (function() {
                  console.log('[Tayseer] JS listeners injected');

                  window.addEventListener('message', function(event) {
                    try {
                      var data = event.data;
                      console.log('[Tayseer] postMessage received: ' + JSON.stringify(data));
                      if (typeof data === 'string') {
                        data = JSON.parse(data);
                      }
                      if (data && data.valid !== undefined) {
                        window.flutter_inappwebview.callHandler(
                          'userVerificationStatus', data
                        );
                      }
                    } catch(e) {
                      console.log('[Tayseer] postMessage error: ' + e);
                    }
                  });

                  var _verStatus;
                  Object.defineProperty(window, 'userVerificationStatus', {
                    get: function() { return _verStatus; },
                    set: function(value) {
                      _verStatus = value;
                      console.log('[Tayseer] userVerificationStatus set: ' + JSON.stringify(value));
                      try {
                        window.flutter_inappwebview.callHandler(
                          'userVerificationStatus', value
                        );
                      } catch(e) {
                        console.log('[Tayseer] callHandler error: ' + e);
                      }
                    },
                    configurable: true
                  });

                  window.addEventListener('didit:session:complete', function(event) {
                    try {
                      var detail = event.detail || {};
                      console.log('[Tayseer] didit:session:complete fired: ' + JSON.stringify(detail));
                      window.flutter_inappwebview.callHandler(
                        'userVerificationStatus',
                        { valid: detail.status === 'Approved' || detail.valid === true }
                      );
                    } catch(e) {
                      console.log('[Tayseer] didit:session:complete error: ' + e);
                    }
                  });
                })();
              ''',
              );
              debugPrint(
                '💉 [VerificationWebViewScreen] JS injection complete',
              );
            },

            onReceivedError: (controller, request, error) {
              debugPrint(
                '💥 [VerificationWebViewScreen] onReceivedError: ${error.description} for ${request.url}',
              );
              if (mounted) setState(() => _isLoading = false);
            },

            onReceivedHttpError: (controller, request, errorResponse) {
              debugPrint(
                '⚠️ [VerificationWebViewScreen] onReceivedHttpError: ${errorResponse.statusCode} for ${request.url}',
              );
            },

            onConsoleMessage: (controller, consoleMessage) {
              debugPrint(
                '🖥️ [VerificationWebViewScreen] JS Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}',
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
  /// GET /user/verify-id-didit → returns webview URL
  static Future<String?> getVerificationUrl() async {
    debugPrint('🔧 [VerificationService] getVerificationUrl() called');
    try {
      final apiService = getIt<ApiService>();
      debugPrint(
        '🔧 [VerificationService] Calling GET /user/verify-id-didit...',
      );

      final response = await apiService.get(endPoint: '/user/verify-id-didit');

      debugPrint(
        '🔧 [VerificationService] getVerificationUrl raw response: $response',
      );

      if (response['success'] == true) {
        final url = response['data']['webview'] as String?;
        debugPrint(
          '🔧 [VerificationService] getVerificationUrl extracted url: $url',
        );
        return url;
      }

      debugPrint('❌ [VerificationService] getVerificationUrl: success != true');
      return null;
    } on DioException catch (e) {
      debugPrint(
        '❌ [VerificationService] getVerificationUrl DioException: ${e.message}',
      );
      debugPrint(
        '❌ [VerificationService] getVerificationUrl DioException response: ${e.response?.data}',
      );
      return null;
    } catch (e) {
      debugPrint('❌ [VerificationService] getVerificationUrl Error: $e');
      return null;
    }
  }

  /// GET /user/get-user-verification-status → returns isVerified bool
  static Future<bool?> getUserVerificationStatus() async {
    debugPrint('🔧 [VerificationService] getUserVerificationStatus() called');
    try {
      final apiService = getIt<ApiService>();
      debugPrint(
        '🔧 [VerificationService] Calling GET /user/get-user-verification-status...',
      );

      final response = await apiService.get(
        endPoint: '/user/get-user-verification-status',
      );

      debugPrint(
        '🔧 [VerificationService] getUserVerificationStatus raw response: $response',
      );

      if (response['success'] == true) {
        final isVerified = response['data']['isVerified'] as bool?;
        debugPrint(
          '🔧 [VerificationService] getUserVerificationStatus isVerified: $isVerified',
        );
        return isVerified;
      }

      debugPrint(
        '❌ [VerificationService] getUserVerificationStatus: success != true',
      );
      return null;
    } on DioException catch (e) {
      debugPrint(
        '❌ [VerificationService] getUserVerificationStatus DioException: ${e.message}',
      );
      debugPrint(
        '❌ [VerificationService] getUserVerificationStatus DioException response: ${e.response?.data}',
      );
      return null;
    } catch (e) {
      debugPrint('❌ [VerificationService] getUserVerificationStatus Error: $e');
      return null;
    }
  }
}
