import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tayseer/my_import.dart';

/// نتيجة دفع Paymob عبر WebView
enum PaymobWebViewResult { success, rejected, pending, closed }

/// شاشة WebView لدفع Paymob — تُستخدم للـ subscriptions على Android
/// بتفتح الـ webviewUrl وبتراقب الـ redirect للتعرف على نتيجة الدفع
class PaymobWebViewScreen extends StatefulWidget {
  final String webviewUrl;

  const PaymobWebViewScreen({super.key, required this.webviewUrl});

  @override
  State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  bool _isLoading = true;
  bool _resultHandled = false;

  /// Paymob بيعمل redirect لـ URL فيه transaction_response بعد الدفع
  /// الـ URL بيحتوي على: success=true/false, pending=true/false
  void _handleUrl(String url) {
    if (_resultHandled) return;
    if (!mounted) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Paymob callback URLs بتحتوي على success أو pending في الـ query params
    final hasSuccessParam =
        uri.queryParameters.containsKey('success') ||
        uri.queryParameters.containsKey('pending') ||
        url.contains('transaction_response') ||
        url.contains('post_pay') ||
        url.contains('accept.paymobsolutions.com/api/acceptance/post_pay');

    if (!hasSuccessParam) return;

    _resultHandled = true;

    final successStr = uri.queryParameters['success'] ?? '';
    final pendingStr = uri.queryParameters['pending'] ?? '';

    final PaymobWebViewResult result;
    if (pendingStr == 'true') {
      result = PaymobWebViewResult.pending;
    } else if (successStr == 'true') {
      result = PaymobWebViewResult.success;
    } else {
      result = PaymobWebViewResult.rejected;
    }

    debugPrint('💳 [PaymobWebView] URL: $url');
    debugPrint('💳 [PaymobWebView] Result: $result');

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            if (!_resultHandled) {
              _resultHandled = true;
              Navigator.of(context).pop(PaymobWebViewResult.closed);
            }
          },
        ),
        title: Text(
          context.tr('payment'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
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
              useHybridComposition: true,
              disableDefaultErrorPage: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, url) {
              if (url != null) {
                _handleUrl(url.toString());
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              _handleUrl(url);
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              if (url != null) {
                _handleUrl(url.toString());
              }
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
