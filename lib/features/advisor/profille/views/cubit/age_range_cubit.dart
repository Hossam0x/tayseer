import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgeRangeCubit extends Cubit<RangeValues> {
  AgeRangeCubit() : super(const RangeValues(18, 60)); // Default values

  void updateRange(RangeValues newRange) => emit(newRange);
}
