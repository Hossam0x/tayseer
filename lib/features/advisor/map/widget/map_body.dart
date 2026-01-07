import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/features/advisor/map/widget/bottom_card.dart';
import 'package:tayseer/features/advisor/map/widget/control_buttons.dart';
import 'package:tayseer/features/advisor/map/widget/loading_overlay.dart';
import 'package:tayseer/my_import.dart';

class MapBody extends StatefulWidget {
  const MapBody({super.key, required this.eventsCubit});
  final EventsCubit eventsCubit;

  @override
  State<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<MapBody> {
  gmaps.GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    widget.eventsCubit.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsCubit, EventsState>(
      listenWhen: (previous, current) =>
          previous.advisorEventsState != current.advisorEventsState,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: state.errorMessage!, isError: true),
          );
        }
      },
      builder: (context, state) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: context.height * 0.1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context, false),
              ),
              centerTitle: true,
              title: Text(
                context.tr('select_location_on_map'),
                style: Styles.textStyle14Bold.copyWith(color: Colors.white),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.defaultGradient,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: Stack(
                children: [
                  gmaps.GoogleMap(
                    initialCameraPosition: gmaps.CameraPosition(
                      target: widget.eventsCubit.initialPosition,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (state.currentPosition != null) {
                        controller.animateCamera(
                          gmaps.CameraUpdate.newLatLngZoom(
                            state.currentPosition!,
                            15,
                          ),
                        );
                      }
                    },
                    onTap: widget.eventsCubit.onMapTapped,
                    markers: state.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                  ),

                  if (state.isLoadingLocation) const LoadingOverlay(),

                  if (state.selectedPosition != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BottomCard(
                        state: state,
                        onConfirm: () => _confirmLocation(context, state),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 250,
                    child: ControlButtons(
                      onMyLocation: () async {
                        await widget.eventsCubit.getCurrentLocation();
                        if (widget.eventsCubit.state.currentPosition != null) {
                          _mapController?.animateCamera(
                            gmaps.CameraUpdate.newLatLngZoom(
                              widget.eventsCubit.state.currentPosition!,
                              15,
                            ),
                          );
                        }
                      },
                      onZoomIn: () => _mapController?.animateCamera(
                        gmaps.CameraUpdate.zoomIn(),
                      ),
                      onZoomOut: () => _mapController?.animateCamera(
                        gmaps.CameraUpdate.zoomOut(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLocation(BuildContext context, EventsState state) {
    if (state.selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('please_select_location_on_map'),
          isError: true,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
