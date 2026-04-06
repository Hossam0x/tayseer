import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

class _VerificationWebViewScreenState
    extends State<VerificationWebViewScreen> {
  bool _isLoading = true;
  InAppWebViewController? _webViewController;

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
            initialUrlRequest: URLRequest(
              url: WebUri(widget.webviewUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useOnLoadResource: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'userVerificationStatus',
                callback: (args) {
                  try {
                    final data = args.isNotEmpty ? args[0] : null;
                    bool isValid = false;

                    if (data is Map) {
                      isValid = data['valid'] == true;
                    } else if (data is String) {
                      isValid = data.contains('"valid":true') ||
                          data.contains('"valid": true');
                    }

                    widget.onVerificationComplete(isValid);
                    if (mounted) Navigator.pop(context, isValid);
                  } catch (_) {
                    widget.onVerificationComplete(false);
                    if (mounted) Navigator.pop(context, false);
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              if (mounted) setState(() => _isLoading = false);

              // Inject JS to catch all possible event types from Didit
              await controller.evaluateJavascript(source: '''
                (function() {
                  // Listen for postMessage
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

                  // Override direct assignment
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
                })();
              ''');
            },
            onReceivedError: (controller, request, error) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class VerificationService {
  static Future<String?> getVerificationUrl() async {
    try {
      final apiService = getIt<ApiService>();

      final response = await apiService.get(
        endPoint: '/user/verify-id-didit',
      );

      if (response['success'] == true) {
        return response['data']['webview'] as String?;
      }
      return null;
    } on DioException catch (e) {
      print('❌ Error: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
}