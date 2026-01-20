import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';

class WithdrawState extends Equatable {
  final double currentBalance;
  final double amount;
  final double fees;
  final double netAmount;
  final WithdrawMethod method;
  final String accountNumber;
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;
  final String? successMessage;
  final List<WithdrawModel> withdrawHistory;
  final List<File> images;

  const WithdrawState({
    this.currentBalance = 3250.0,
    this.amount = 0,
    this.fees = 0,
    this.netAmount = 0,
    this.method = WithdrawMethod.bankAccount,
    this.accountNumber = 'SAXXXXXXXXXXXXXXXXXXXXX',
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
    this.successMessage,
    this.withdrawHistory = const [],
    this.images = const [],
  });

  @override
  List<Object?> get props => [
    currentBalance,
    amount,
    fees,
    netAmount,
    method,
    accountNumber,
    isLoading,
    isValid,
    errorMessage,
    successMessage,
    withdrawHistory,
    images,
  ];

  WithdrawState copyWith({
    double? currentBalance,
    double? amount,
    double? fees,
    double? netAmount,
    WithdrawMethod? method,
    String? accountNumber,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    String? successMessage,
    List<WithdrawModel>? withdrawHistory,
    List<File>? images,
  }) {
    return WithdrawState(
      currentBalance: currentBalance ?? this.currentBalance,
      amount: amount ?? this.amount,
      fees: fees ?? this.fees,
      netAmount: netAmount ?? this.netAmount,
      method: method ?? this.method,
      accountNumber: accountNumber ?? this.accountNumber,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      withdrawHistory: withdrawHistory ?? this.withdrawHistory,
      images: images ?? this.images,
    );
  }
}
