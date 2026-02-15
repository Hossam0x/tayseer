import 'package:intl/intl.dart';
import 'package:tayseer/my_import.dart';
import '../model/event_detail_model.dart';
import '../repo/event_detail_repository.dart';
import 'event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({required this.repo}) : super(const EventDetailState());

  final EventDetailRepository repo;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceBeforeDiscountController = TextEditingController();
  final priceAfterDiscountController = TextEditingController();

  String? _eventId;

  //============ Fetch ============//

  Future<void> fetchEventDetail(String id) async {
    _eventId = id;
    emit(state.copyWith(eventDetailStatus: CubitStates.loading));

    final result = await repo.getEventDetails(id: id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          eventDetailStatus: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (event) {
        _populateForm(event);
        emit(
          state.copyWith(eventDetailStatus: CubitStates.success, event: event),
        );
      },
    );
  }

  //============ Populate Form - Direct from Model ============//

  void _populateForm(EventDetailModel event) {
    // Controllers
    titleController.text = event.title;
    descriptionController.text = event.description;
    priceBeforeDiscountController.text = event.priceBeforeDiscount.toString();
    priceAfterDiscountController.text = event.priceAfterDiscount.toString();

    // State - مباشرة من الموديل
    emit(
      state.copyWith(
        eventDate: _parseDate(event.date),
        startTime: _parseTime(event.startTime),
        duration: event.duration, // 👈 مباشرة
        // numberOfAttendees: event.numberOfReservations.toString(), // 👈 مباشرة
        // existingImages: event.images ?? [],
      ),
    );
  }

  //============ Update ============//

  Future<void> updateEvent() async {
    if (_eventId == null) return;
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(updateEventStatus: CubitStates.loading));

    final result = await repo.updateEvent(
      latitude: state.event?.latitude.toString() ?? '',
      longitude: state.event?.longitude.toString() ?? '',
      location: state.event?.location ?? '',
      id: _eventId!,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      date: _formatDate(state.eventDate),
      startTime: _formatTime(state.startTime),
      priceBeforeDiscount: priceBeforeDiscountController.text.trim(),
      priceAfterDiscount: priceAfterDiscountController.text.trim(),
      duration: state.duration ?? '',
      numberOfAttendees: state.numberOfAttendees ?? '',
      images: state.pickedImages,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          updateEventStatus: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(updateEventStatus: CubitStates.success)),
    );
  }

  //============ Setters ============//

  void setEventDate(DateTime date) => emit(state.copyWith(eventDate: date));

  void setStartTime(TimeOfDay time) => emit(state.copyWith(startTime: time));

  void setDuration(String? val) => emit(state.copyWith(duration: val));

  void setNumberOfAttendees(String? val) =>
      emit(state.copyWith(numberOfAttendees: val));

  //============ Images ============//

  void addPickedImages(List<XFile> images) {
    if (images.isEmpty) return;
    emit(state.copyWith(pickedImages: [...state.pickedImages, ...images]));
  }

  void removePickedImageAt(int index) {
    if (index < 0 || index >= state.pickedImages.length) return;
    final list = List<XFile>.from(state.pickedImages)..removeAt(index);
    emit(state.copyWith(pickedImages: list));
  }

  void removeExistingImageAt(int index) {
    if (index < 0 || index >= state.existingImages.length) return;
    final list = List<String>.from(state.existingImages)..removeAt(index);
    emit(state.copyWith(existingImages: list));
  }

  //============ Helpers ============//

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      var hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

      if (timeStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (timeStr.toUpperCase().contains('AM') && hour == 12) hour = 0;

      return TimeOfDay(hour: hour % 24, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  //============ Reset ============//

  void resetUpdateStatus() =>
      emit(state.copyWith(updateEventStatus: CubitStates.initial));

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    priceBeforeDiscountController.clear();
    priceAfterDiscountController.clear();
    _eventId = null;
    emit(state.reset());
  }

  @override
  Future<void> close() {
    titleController.dispose();
    descriptionController.dispose();
    priceBeforeDiscountController.dispose();
    priceAfterDiscountController.dispose();
    return super.close();
  }
}
