import 'package:flutter_bloc/flutter_bloc.dart';

class RatingCubit extends Cubit<int> {
  RatingCubit() : super(0);

  void setRating(int rating) => emit(rating);

  void reset() => emit(0);
}
