import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';

enum WithdrawMethodsStatus { initial, loading, loaded, error }

class WithdrawState extends Equatable {
  final num walletBalance;
  final String walletCurrency;
  final double amount;
  final double fees;
  final double netAmount;
  final WithdrawMethod? method;
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;
  final WithdrawModel? lastWithdrawResult;
  final List<File> images;

  // Available methods + fee from API
  final WithdrawMethodsStatus methodsStatus;
  final List<WithdrawMethod> availableMethods;
  final double feePercentage; // e.g. 2.5 means 2.5%

  // Bank account fields
  final String iban;
  final String accountHolderName;
  final String bankName;

  // Mobile wallet field
  final String phone;

  static const double minWithdrawAmount = 100.0;

  const WithdrawState({
    this.walletBalance = 0,
    this.walletCurrency = 'USD',
    this.amount = 0,
    this.fees = 0,
    this.netAmount = 0,
    this.method,
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
    this.lastWithdrawResult,
    this.images = const [],
    this.methodsStatus = WithdrawMethodsStatus.initial,
    this.availableMethods = const [],
    this.feePercentage = 0,
    this.iban = '',
    this.accountHolderName = '',
    this.bankName = '',
    this.phone = '',
  });

  bool get isBank => method == WithdrawMethod.bankAccount;

  /// True when the user has filled in all required payment details
  bool get hasPaymentDetails => isBank
      ? iban.isNotEmpty && accountHolderName.isNotEmpty && bankName.isNotEmpty
      : phone.isNotEmpty;

  /// Button is enabled only when:
  /// 1. Wallet balance >= 100
  /// 2. Entered amount is valid (>= 100)
  /// 3. Payment details are filled
  bool get canSubmit =>
      walletBalance >= minWithdrawAmount && isValid && hasPaymentDetails;

  @override
  List<Object?> get props => [
    walletBalance,
    walletCurrency,
    amount,
    fees,
    netAmount,
    method,
    isLoading,
    isValid,
    errorMessage,
    lastWithdrawResult,
    images,
    methodsStatus,
    availableMethods,
    feePercentage,
    iban,
    accountHolderName,
    bankName,
    phone,
  ];

  WithdrawState copyWith({
    num? walletBalance,
    String? walletCurrency,
    double? amount,
    double? fees,
    double? netAmount,
    WithdrawMethod? method,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    WithdrawModel? lastWithdrawResult,
    List<File>? images,
    WithdrawMethodsStatus? methodsStatus,
    List<WithdrawMethod>? availableMethods,
    double? feePercentage,
    String? iban,
    String? accountHolderName,
    String? bankName,
    String? phone,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return WithdrawState(
      walletBalance: walletBalance ?? this.walletBalance,
      walletCurrency: walletCurrency ?? this.walletCurrency,
      amount: amount ?? this.amount,
      fees: fees ?? this.fees,
      netAmount: netAmount ?? this.netAmount,
      method: method ?? this.method,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastWithdrawResult: clearResult
          ? null
          : (lastWithdrawResult ?? this.lastWithdrawResult),
      images: images ?? this.images,
      methodsStatus: methodsStatus ?? this.methodsStatus,
      availableMethods: availableMethods ?? this.availableMethods,
      feePercentage: feePercentage ?? this.feePercentage,
      iban: iban ?? this.iban,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      phone: phone ?? this.phone,
    );
  }
}
