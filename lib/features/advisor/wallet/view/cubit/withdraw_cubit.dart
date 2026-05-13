import 'package:file_picker/file_picker.dart';
import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/withdraw_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';
import 'package:tayseer/my_import.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  final WalletRepo _walletRepo;

  WithdrawCubit(this._walletRepo) : super(const WithdrawState());

  // ── Sync wallet balance & currency from WalletCubit ──────────────────────

  void syncWallet({required num balance, required String currency}) {
    emit(state.copyWith(walletBalance: balance, walletCurrency: currency));
  }

  // ── Fetch available methods + fee percentage from API ─────────────────────

  Future<void> fetchWithdrawMethods() async {
    emit(state.copyWith(methodsStatus: WithdrawMethodsStatus.loading));

    final result = await _walletRepo.getWithdrawMethods();

    result.fold(
      (failure) => emit(
        state.copyWith(
          methodsStatus: WithdrawMethodsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (data) {
        final firstMethod = data.methods.isNotEmpty ? data.methods.first : null;
        emit(
          state.copyWith(
            methodsStatus: WithdrawMethodsStatus.loaded,
            availableMethods: data.methods,
            feePercentage: data.feePercentage,
            method: firstMethod,
            clearError: true,
          ),
        );
      },
    );
  }

  // ── Submit withdrawal request ─────────────────────────────────────────────

  Future<void> submitWithdraw() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _walletRepo.requestWithdraw(
      method: state.method!,
      amount: state.amount,
      iban: state.isBank ? state.iban : null,
      accountHolderName: state.isBank ? state.accountHolderName : null,
      bankName: state.isBank ? state.bankName : null,
      phone: !state.isBank ? state.phone : null,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (withdrawModel) => emit(
        state.copyWith(isLoading: false, lastWithdrawResult: withdrawModel),
      ),
    );
  }

  // ── Amount ────────────────────────────────────────────────────────────────

  void updateAmount(double amount) {
    if (amount < 0) amount = 0;
    final fees = _calculateFees(amount);
    emit(
      state.copyWith(
        amount: amount,
        fees: fees,
        netAmount: amount - fees,
        isValid: amount >= WithdrawState.minWithdrawAmount,
      ),
    );
  }

  // ── Method selection ──────────────────────────────────────────────────────

  void changeMethod(WithdrawMethod method) {
    // Reset phone when switching methods so hasPaymentDetails re-evaluates
    emit(state.copyWith(method: method, phone: ''));
  }

  // ── Bank fields ───────────────────────────────────────────────────────────

  void updateIban(String value) => emit(state.copyWith(iban: value));
  void updateAccountHolderName(String value) =>
      emit(state.copyWith(accountHolderName: value));
  void updateBankName(String value) => emit(state.copyWith(bankName: value));

  // ── Phone ─────────────────────────────────────────────────────────────────

  void updatePhone(String value) => emit(state.copyWith(phone: value));

  // ── Images ────────────────────────────────────────────────────────────────

  Future<void> pickImagesFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.paths.map((p) => File(p!)).toList();
        emit(
          state.copyWith(
            images: [...state.images, ...newFiles],
            clearError: true,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(errorMessage: 'حدث خطأ أثناء رفع الصور'));
    }
  }

  void removeImage(int index) {
    final updated = List<File>.from(state.images)..removeAt(index);
    emit(state.copyWith(images: updated));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// feePercentage from API is e.g. 2.5 → divide by 100
  double _calculateFees(double amount) => amount * (state.feePercentage / 100);

  void clearResult() => emit(state.copyWith(clearResult: true));
}
