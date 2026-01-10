import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/event_detail/model/event_detail_model.dart';
import 'package:tayseer/features/advisor/event_detail/repo/event_detail_repository.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_state.dart';

class _MockRepo extends Mock implements EventDetailRepository {}

void main() {
  late _MockRepo repo;
  late EventDetailCubit cubit;

  setUp(() {
    repo = _MockRepo();
    cubit = EventDetailCubit(repo);
  });

  tearDown(() {
    cubit.close();
  });

  final sample = EventDetailModel.fromJson({
    "id": "1",
    "title": "t",
    "description": "d",
    "date": "date",
    "numberOfReservations": 0,
    "numberOfTickets": 0,
    "advisor": "a",
    "startTime": "s",
    "endTime": "e",
    "latitude": 0,
    "longitude": 0,
    "reservations": [],
    "priceAfterDiscount": 0,
    "priceBeforeDiscount": 0,
    "location": "l",
    "images": "i",
  });

  blocTest<EventDetailCubit, EventDetailState>(
    'emits loading then success when repo returns data',
    build: () {
      when(() => repo.getEventDetails(id: any(named: 'id')))
          .thenAnswer((_) async => right(sample));
      return cubit;
    },
    act: (c) => c.fetchEvent('1'),
    expect: () => [
      isA<EventDetailState>().having((s) => s.status, 'status', EventDetailStatus.loading),
      isA<EventDetailState>().having((s) => s.status, 'status', EventDetailStatus.success),
    ],
  );
}
