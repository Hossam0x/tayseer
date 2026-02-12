import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:tayseer/my_import.dart';

class EventBodyContent extends StatelessWidget {
  const EventBodyContent({
    super.key,
    required this.eventDescriptionText,
    required this.eventDurationValue,
    required this.attendeesCountValue,
    required this.latitude,
    required this.longitude,
  });

  final String eventDescriptionText;
  final String eventDurationValue;
  final String attendeesCountValue;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final gmaps.LatLng eventLocation = gmaps.LatLng(latitude, longitude);

    final Set<gmaps.Marker> markers = {
      gmaps.Marker(
        markerId: const gmaps.MarkerId('event_location'),
        position: eventLocation,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: gmaps.InfoWindow(title: context.tr('event_location')),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // وصف الحدث
        Text(
          context.tr('event_description_title'),
          style: Styles.textStyle16Bold,
        ),
        Gap(context.responsiveHeight(12)),
        Text(
          eventDescriptionText,
          style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
        ),

        Gap(context.responsiveHeight(24)),

        // مدة الحدث
        Text(context.tr('event_duration'), style: Styles.textStyle14Bold),
        Text(
          eventDurationValue,
          style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
        ),

        Gap(context.responsiveHeight(24)),

        // عدد الحضور
        Text(context.tr('attendees_count'), style: Styles.textStyle14Bold),
        Text(
          attendeesCountValue,
          style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
        ),

        Gap(context.responsiveHeight(24)),

        // الموقع
        Text(context.tr('location_title'), style: Styles.textStyle16Bold),
        Gap(context.responsiveHeight(12)),

        // 🗺️ الخريطة
        Container(
          height: context.responsiveHeight(300),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.kprimaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: eventLocation,
                zoom: 15,
              ),
              markers: markers,

              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              liteModeEnabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
