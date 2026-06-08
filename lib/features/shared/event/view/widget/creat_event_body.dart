import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/core/utils/helper/video_picker_helper.dart';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_time_pic.dart';
import 'package:tayseer/core/widgets/custom_date_picker_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/event/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/shared/event/view/widget/discount_price_container.dart';
import 'package:tayseer/features/shared/event/view/widget/locationp_picker_form_field.dart';
import 'package:tayseer/features/shared/event/view_model/events_cubit.dart';
import 'package:tayseer/features/shared/event/view_model/events_state.dart';
import 'package:tayseer/core/widgets/custom_video_and_edit/custom_uploaded_video_preview.dart';
import 'package:tayseer/my_import.dart';

class CreatEventBody extends StatefulWidget {
  const CreatEventBody({super.key});

  @override
  State<CreatEventBody> createState() => _CreatEventBodyState();
}

class _CreatEventBodyState extends State<CreatEventBody> {
  @override
  initState() {
    super.initState();
    final eventsCubit = context.read<EventsCubit>();
    eventsCubit.discountEvent();
  }

  final _videoPicker = VideoPickerHelper();
  final _imagePicker = ImagePickerHelper();
  bool _isLoadingDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final eventsCubit = context.read<EventsCubit>();
    final state = context.watch<EventsCubit>().state;

    return BlocListener<EventsCubit, EventsState>(
      listenWhen: (previous, current) =>
          previous.advisorEventsState != current.advisorEventsState,
      listener: (context, state) {
        if (state.advisorEventsState == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('succ_event'),
              isSuccess: true,
            ),
          );
          context.popUntil(routeName: AppRouter.kAdvisorLayoutView);
        } else if (state.advisorEventsState == CubitStates.failure) {
          // Only pop if the loading dialog was previously shown
          if (_isLoadingDialogShown) {
            _isLoadingDialogShown = false;
            context.pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr(state.errorMessage ?? "😔"),
              isError: true,
            ),
          );
        } else if (state.advisorEventsState == CubitStates.loading) {
          _isLoadingDialogShown = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(child: const CustomloadingApp()),
          );
        }
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 125.h,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsData.homeBarBackgroundImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: SimpleAppBar(title: context.tr('create_event')),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Form(
                      key: eventsCubit.creatEventformKey,
                      child: AutofillGroup(
                        child: Column(
                          children: [
                            CustomTextFormField(
                              maxLength: 30,
                              hintText: context.tr('title_events'),
                              controller: eventsCubit.eventTitleController,
                            ),
                            Gap(context.responsiveHeight(16)),
                            CustomTextFormField(
                              maxLength: 250,
                              hintText: context.tr('event_description'),
                              maxLines: 5,
                              controller:
                                  eventsCubit.eventDescriptionController,
                              onChanged: (val) => eventsCubit
                                  .setEventDescriptionLength(val.length),
                            ),
                            Gap(context.responsiveHeight(3)),
                            BlocBuilder<EventsCubit, EventsState>(
                              buildWhen: (previous, current) =>
                                  previous.eventDescriptionLength !=
                                  current.eventDescriptionLength,
                              builder: (context, s) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${s.eventDescriptionLength}/250',
                                    style: Styles.textStyle12.copyWith(
                                      color: AppColors.kGreyColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Gap(context.responsiveHeight(16)),

                            /// 3. التاريخ والوقت
                            DatePickerField(
                              allowPastDates: false,
                              validator: (value) {
                                if (value == null) {
                                  return context.tr('required');
                                }
                                return null;
                              },
                              initialValue: state.eventDate,
                              placeholder: context.tr('event_date'),
                              onDateChanged: (date) {
                                eventsCubit.setEventDate(date);
                              },
                            ),

                            Gap(context.responsiveHeight(16)),

                            TimePickerFormField(
                              disablePastTime: true,
                              initialValue: state.startTime,
                              onChanged: (value) {
                                eventsCubit.setStartTime(value);
                              },
                              placeholder: context.tr('start_time'),
                              validator: (value) {
                                if (value == null) {
                                  return context.tr('required');
                                }
                                return null;
                              },
                              minDateForTime: state.eventDate,
                            ),
                            Gap(context.responsiveHeight(16)),

                            /// 4.  (Dropdown)
                            CustomDropdownFormField<String>(
                              hint: context.tr('event_type'),
                              value: state.duration,
                              items: [
                                DropdownMenuItem(
                                  value: '15 minutes',
                                  child: Text(
                                    '15 minutes',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '30 minutes',
                                  child: Text(
                                    '30 minutes',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '1 hour',
                                  child: Text(
                                    '1 hour',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '2 hours',
                                  child: Text(
                                    '2 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '3 hours',
                                  child: Text(
                                    '3 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '4 hours',
                                  child: Text(
                                    '4 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '5 hours',
                                  child: Text(
                                    '5 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '6 hours',
                                  child: Text(
                                    '6 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '7 hours',
                                  child: Text(
                                    '7 hours',
                                    style: Styles.textStyle14,
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  eventsCubit.setExperienceYears(val),
                              validator: (value) =>
                                  value == null ? context.tr('required') : null,
                            ),
                            Gap(context.responsiveHeight(16)),

                            LocationPickerFormField(
                              initialValue:
                                  state.locationAddress != null &&
                                  state.locationAddress!.isNotEmpty,

                              onTap: () async {
                                await context.pushNamed(
                                  AppRouter.kMapView,
                                  arguments: {'cubit': eventsCubit},
                                );

                                // if (result == true && context.mounted) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     CustomSnackBar(
                                //       context,
                                //       text: context.tr(
                                //         'location_selected_successfully',
                                //       ),
                                //       isSuccess: true,
                                //     ),
                                //   );
                                // }
                              },

                              validator: (value) {
                                if (state.locationAddress == null ||
                                    state.locationAddress!.isEmpty) {
                                  return context.tr('required');
                                }
                                return null;
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    state.hasLocation
                                        ? Icons.location_on
                                        : Icons.location_on_outlined,
                                    color: state.hasLocation
                                        ? AppColors.kprimaryColor.withOpacity(
                                            0.8,
                                          )
                                        : AppColors.kprimaryColor.withOpacity(
                                            0.3,
                                          ),
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.hasLocation
                                              ? context.tr(
                                                  'event_location_selected',
                                                )
                                              : context.tr('event_location'),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: state.hasLocation
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: state.hasLocation
                                                ? Colors.grey.shade600
                                                : AppColors.kprimaryColor
                                                      .withOpacity(0.5),
                                          ),
                                        ),
                                        if (state.locationAddress != null &&
                                            state.locationAddress!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              state.locationAddress!,
                                              style: Styles.textStyle12SemiBold
                                                  .copyWith(
                                                    color: AppColors.kgreyColor
                                                        .withOpacity(0.7),
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(context.responsiveHeight(16)),

                            /// 6. الأسعار
                            CustomTextFormField(
                              maxLength: 5,
                              isNumber: true,
                              controller: eventsCubit
                                  .eventPriceBeforeDiscountController,
                              hintText: context.tr(
                                'event_price_before_discount',
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    CurrencyHelper.getEventCurrencySymbol(),
                                    style: Styles.textStyle14Bold.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(context.responsiveHeight(16)),
                            CustomTextFormField(
                              maxLength: 5,
                              isNumber: true,
                              controller:
                                  eventsCubit.eventPriceAfterDiscountController,
                              hintText: context.tr(
                                'event_price_after_discount',
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    CurrencyHelper.getEventCurrencySymbol(),
                                    style: Styles.textStyle14Bold.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                state.discountResult != null
                                    ? '${context.tr('application_rate')}: ${state.discountResult!.percentage}%'
                                    : '',
                                style: Styles.textStyle12,
                              ),
                            ),
                            Gap(context.responsiveHeight(16)),
                            DiscountPriceContainer(
                              controller:
                                  eventsCubit.eventPriceAfterDiscountController,
                              discountPercentage:
                                  state.discountResult?.percentage ?? 0,
                            ),
                            Gap(context.responsiveHeight(16)),

                            /// 7. عدد الحضور (Text field)
                            CustomTextFormField(
                              maxLength: 5,
                              isNumber: true,
                              controller:
                                  eventsCubit.numberOfAttendeesController,
                              hintText: context.tr('attendees_count'),
                              onChanged: (val) =>
                                  eventsCubit.numberOfffAttendees(val),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? context.tr('required')
                                  : null,
                            ),
                            Gap(context.responsiveHeight(24)),

                            CustomUploadContainer(
                              icon: Icons.camera_alt,
                              title: context.tr('add_event_image'),
                              subtitle: context.tr('add_4_images_hint'),
                              onTap: () async {
                                final images = await _imagePicker
                                    .pickMultipleFromGallery();
                                if (images != null && images.isNotEmpty) {
                                  eventsCubit.addPickedImages(images);
                                }
                              },
                              valueGetter: () => eventsCubit.pickedImages
                                  .map((e) => e.path)
                                  .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return context.tr('required_images');
                                }
                                return null;
                              },
                            ),

                            Gap(context.responsiveHeight(16)),

                            BlocBuilder<EventsCubit, EventsState>(
                              builder: (context, state) {
                                final images = state.pickedImages;
                                if (images.isEmpty)
                                  return const SizedBox.shrink();
                                return SizedBox(
                                  height: context.responsiveHeight(150),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    separatorBuilder: (c, i) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final img = images[index];
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: context.responsiveWidth(120),
                                            height: context.responsiveHeight(
                                              150,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF70C1B3),
                                              ),
                                              color: const Color(0xFFEFFFFC),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                File(img.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                eventsCubit.removePickedImageAt(
                                                  index,
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.kWhiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            Gap(context.responsiveHeight(24)),

                            UploadVideoWidget(
                              onTap: () async {
                                final video = await _videoPicker
                                    .pickFromGallery();
                                if (video != null) {
                                  eventsCubit.setPickedVideo(video);
                                  eventsCubit.setVideoLoading(true);
                                }
                              },
                            ),
                            Gap(context.responsiveHeight(10)),
                            Center(
                              child: Text(
                                context.tr('video_size_hint'),

                                style: Styles.textStyle12.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Gap(context.responsiveHeight(15)),
                            if (state.pickedVideo != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomUploadedVideoPreview(
                                      video: state.pickedVideo!,
                                      onRemove: () {
                                        eventsCubit.removePickedVideo();
                                      },
                                      onInitialized: () {
                                        eventsCubit.setVideoLoaded();
                                      },
                                    ),
                                    if (state.isVideoLoading)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.35),
                                          child: const Center(
                                            child: CustomloadingApp(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            Gap(context.responsiveHeight(40)),

                            /// زر إنشاء
                            CustomBotton(
                              useGradient: true,
                              title: context.tr('create_event'),
                              onPressed: () {
                                eventsCubit.createEvent();
                              },
                            ),

                            Gap(context.responsiveHeight(20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
