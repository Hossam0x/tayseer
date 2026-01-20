import 'dart:async';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import '../../../../../my_import.dart';

class CustomOtpTimer extends StatefulWidget {
  final Function(String) onOtpSubmitted;

  const CustomOtpTimer({super.key, required this.onOtpSubmitted});

  @override
  _CustomOtpTimerState createState() => _CustomOtpTimerState();
}

class _CustomOtpTimerState extends State<CustomOtpTimer> {
  Timer? _timer;
  int _start = 300;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isTimerActive = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetAndResend() {
    context.read<AuthCubit>().resendCode();
    setState(() {
      _start = 300;
      _isTimerActive = true;
    });
    _startTimer();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60);
    final secondsRemaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(context.tr('otp_sub_title'), style: Styles.textStyle14),
          SizedBox(height: context.height * 0.05),

          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xfff8d3da),
                    width: 1.4,
                  ),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: AppColors.kprimaryColor,
                    width: 1.4,
                  ),
                ),
              ),
              submittedPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xfff8d3da),
                    width: 1.4,
                  ),
                ),
              ),
              onCompleted: (value) => widget.onOtpSubmitted(value),
            ),
          ),

          SizedBox(height: context.height * 0.03),

          _isTimerActive
              ? Column(
                  children: [
                    Text(
                      context.tr('resend_code_after'),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      _formatTime(_start),
                      style: Styles.textStyle12.copyWith(
                        color: HexColor('4d81e7'),
                      ),
                    ),
                  ],
                )
              : TextButton(
                  onPressed: _resetAndResend,
                  child: Text(
                    context.tr('resend_code'),
                    style: Styles.textStyle12.copyWith(
                      color: HexColor('4d81e7'),
                      decoration: TextDecoration.underline,
                      decorationColor: HexColor('4d81e7'),
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
