import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/my_import.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(const WalletState());

  // البيانات التجريبية لمعاملات المحفظة
  final List<TransactionModel> _demoWalletTransactions = [
    TransactionModel(
      id: '1',
      title: 'مبلغ مسترد',
      subtitle: 'استرداد مبلغ الحجز',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 1000,
      isPositive: true,
      type: TransactionType.refund,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '2',
      title: 'طلب سحب',
      subtitle: 'طلب سحب إلى البنك',
      date: '24 ديسمبر 2025',
      time: '11:03 م',
      amount: 1000,
      isPositive: false,
      type: TransactionType.withdraw,
      category: TransactionCategory.wallet,
      pending: true,
    ),
    TransactionModel(
      id: '3',
      title: 'سحب',
      subtitle: 'سحب من المحفظة',
      date: '24 ديسمبر 2025',
      time: '08:36 م',
      amount: 1000,
      isPositive: false,
      type: TransactionType.withdraw,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '4',
      title: 'اشتراك جديد',
      subtitle: 'تجديد الاشتراك',
      date: '24 ديسمبر 2025',
      time: '05:02 م',
      amount: 180,
      isPositive: true,
      type: TransactionType.subscription,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '5',
      title: 'سحب',
      subtitle: 'سحب من المحفظة',
      date: '24 ديسمبر 2025',
      time: '04:49 م',
      amount: 500,
      isPositive: false,
      type: TransactionType.withdraw,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '6',
      title: 'اشتراك جديد',
      subtitle: 'اشتراك جديد',
      date: '24 ديسمبر 2025',
      time: '04:06 م',
      amount: 120,
      isPositive: true,
      type: TransactionType.subscription,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '1',
      title: 'مبلغ مسترد',
      subtitle: 'استرداد مبلغ الحجز',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 1300,
      isPositive: true,
      type: TransactionType.refund,
      category: TransactionCategory.wallet,
    ),
    TransactionModel(
      id: '1',
      title: 'مبلغ مسترد',
      subtitle: 'استرداد مبلغ الحجز',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 3150,
      isPositive: true,
      type: TransactionType.refund,
      category: TransactionCategory.wallet,
    ),
  ];

  // البيانات التجريبية لسجل الحجوزات
  final List<TransactionModel> _demoBookingTransactions = [
    TransactionModel(
      id: '7',
      title: 'حجز حدث',
      subtitle: 'حجز تذكرة حدث',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 250,
      isPositive: true,
      type: TransactionType.booking,
      category: TransactionCategory.booking,
    ),
    TransactionModel(
      id: '8',
      title: 'حجز جلسة',
      subtitle: 'حجز جلسة استشارية',
      date: '24 ديسمبر 2025',
      time: '11:03 م',
      amount: 300,
      isPositive: true,
      type: TransactionType.booking,
      category: TransactionCategory.booking,
    ),
    TransactionModel(
      id: '9',
      title: 'حجز حدث',
      subtitle: 'حجز تذكرة حدث',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 180,
      isPositive: true,
      type: TransactionType.booking,
      category: TransactionCategory.booking,
    ),
    TransactionModel(
      id: '10',
      title: 'حجز جلسة',
      subtitle: 'حجز جلسة استشارية',
      date: '24 ديسمبر 2025',
      time: '11:03 م',
      amount: 150,
      isPositive: true,
      type: TransactionType.booking,
      category: TransactionCategory.booking,
    ),
    TransactionModel(
      id: '11',
      title: 'حجز حدث',
      subtitle: 'حجز تذكرة حدث',
      date: '24 ديسمبر 2025',
      time: '11:16 م',
      amount: 220,
      isPositive: true,
      type: TransactionType.booking,
      category: TransactionCategory.booking,
    ),
  ];

  Future<void> loadWalletTransactions() async {
    emit(
      state.copyWith(
        walletTransactions: _demoWalletTransactions,
        status: WalletStatus.loaded,
      ),
    );
  }

  Future<void> loadBookingTransactions() async {
    emit(
      state.copyWith(
        bookingTransactions: _demoBookingTransactions,
        status: WalletStatus.loaded,
      ),
    );
  }

  Future<void> loadAllTransactions() async {
    emit(
      state.copyWith(
        walletTransactions: _demoWalletTransactions,
        bookingTransactions: _demoBookingTransactions,
        status: WalletStatus.loaded,
      ),
    );
  }
}
