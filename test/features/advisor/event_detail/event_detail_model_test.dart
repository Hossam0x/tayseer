import 'package:flutter_test/flutter_test.dart';
import 'package:tayseer/features/advisor/event_detail/model/event_detail_model.dart';

void main() {
  test('EventDetailModel parses JSON correctly', () {
    final json = {
      "id": "695f7041585359d27b031b3d",
      "title": "hhdhd",
      "description": "bdbbdbd",
      "date": "18 يناير 2000",
      "numberOfReservations": 1,
      "numberOfTickets": 9999,
      "advisor": "hossam dif",
      "startTime": "10:51 AM",
      "endTime": "01:51 PM",
      "latitude": 31.4404,
      "longitude": 31.6813416,
      "reservations": [
        {"image": "https://example.com/img.png"}
      ],
      "priceAfterDiscount": 88,
      "priceBeforeDiscount": 8885,
      "location": "Some location",
      "images": "https://example.com/event.jpg"
    };

    final model = EventDetailModel.fromJson(json);

    expect(model.id, '695f7041585359d27b031b3d');
    expect(model.title, 'hhdhd');
    expect(model.reservationsImages.length, 1);
    expect(model.latitude, 31.4404);
    expect(model.priceAfterDiscount, 88);
  });
}
