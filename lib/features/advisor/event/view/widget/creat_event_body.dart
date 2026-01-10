import 'package:tayseer/core/utils/helper/video_picker_helper.dart';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_time_pic.dart';
import 'package:tayseer/core/widgets/date_picker_field.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/my_import.dart';

class CreatEventBody extends StatefulWidget {
  const CreatEventBody({super.key});

  @override
  State<CreatEventBody> createState() => _CreatEventBodyState();
}

class _CreatEventBodyState extends State<CreatEventBody> {
  final _videoPicker = VideoPickerHelper();
  final _imagePicker = ImagePickerHelper();

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
          context.pop();
          context.pop();
        } else if (state.advisorEventsState == CubitStates.failure) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? "😔",
              isError: true,
            ),
          );
        } else if (state.advisorEventsState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CustomloadingApp(),
          );
        }
      },
      child: CustomScrollView(
        slivers: [
          CustomSliverAppBarEvent(
            title: context.tr('create_event'),
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Form(
                key: eventsCubit.creatEventformKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: context.tr('title_events'),
                      controller: eventsCubit.eventTitleController,
                    ),
                    Gap(context.responsiveHeight(16)),
                    CustomTextFormField(
                      hintText: context.tr('event_description'),
                      maxLines: 5,
                      controller: eventsCubit.eventDescriptionController,
                    ),
                    Gap(context.responsiveHeight(3)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${eventsCubit.eventDescriptionController.text.length}/250',
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kGreyColor,
                        ),
                      ),
                    ),
                    Gap(context.responsiveHeight(16)),

                    /// 3. التاريخ والوقت
                    DatePickerField(
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
                    ),
                    Gap(context.responsiveHeight(16)),

                    /// 4.  (Dropdown)
                    CustomDropdownFormField<String>(
                      hint: context.tr('event_type'),
                      value: state.duration,
                      items: [
                        DropdownMenuItem(
                          value: '15 minutes',
                          child: Text('15 minutes', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '30 minutes',
                          child: Text('30 minutes', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '1 hour',
                          child: Text('1 hour', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '2 hours',
                          child: Text('2 hours', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '3 hours',
                          child: Text('3 hours', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '4 hours',
                          child: Text('4 hours', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '5 hours',
                          child: Text('5 hours', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '6 hours',
                          child: Text('6 hours', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '7 hours',
                          child: Text('7 hours', style: Styles.textStyle14),
                        ),
                      ],
                      onChanged: (val) => eventsCubit.setExperienceYears(val),
                      validator: (value) =>
                          value == null ? context.tr('required') : null,
                    ),
                    Gap(context.responsiveHeight(16)),

                    ///map
                    GestureDetector(
                      onTap: () async {
                        final result = await context.pushNamed(
                          AppRouter.kMapView,
                          arguments: {'cubit': eventsCubit},
                        );
                        if (result == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackBar(
                              context,
                              text: 'تم تحديد الموقع بنجاح',
                              isSuccess: true,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.kprimaryColor.withOpacity(0.3),
                            width: state.hasLocation ? 1.5 : 1,
                          ),
                          boxShadow: state.hasLocation
                              ? [
                                  BoxShadow(
                                    color: AppColors.kprimaryColor.withOpacity(
                                      0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.hasLocation
                                  ? Icons.location_on
                                  : Icons.location_on_outlined,
                              color: state.hasLocation
                                  ? AppColors.kprimaryColor.withOpacity(0.8)
                                  : AppColors.kprimaryColor.withOpacity(0.3),
                              size: 22.sp,
                            ),
                            SizedBox(width: 12.w),

                            // 📝 Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // العنوان الرئيسي
                                  Text(
                                    state.hasLocation
                                        ? context.tr('event_location_selected')
                                        : context.tr('event_location'),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: state.hasLocation
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: state.hasLocation
                                          ? Colors.grey.shade600
                                          : AppColors.kprimaryColor.withOpacity(
                                              0.5,
                                            ),
                                    ),
                                  ),

                                  // العنوان التفصيلي
                                  if (state.locationAddress != null &&
                                      state.locationAddress!.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      state.locationAddress!,
                                      style: Styles.textStyle12SemiBold
                                          .copyWith(
                                            color: AppColors.kgreyColor
                                                .withOpacity(0.7),
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(context.responsiveHeight(16)),

                    /// 6. الأسعار
                    CustomTextFormField(
                      isNumber: true,
                      controller:
                          eventsCubit.eventPriceBeforeDiscountController,
                      hintText: context.tr('event_price_before_discount'),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('currency_rs'),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.kprimaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(context.responsiveHeight(16)),
                    CustomTextFormField(
                      isNumber: true,
                      controller: eventsCubit.eventPriceAfterDiscountController,
                      hintText: context.tr('event_price_after_discount'),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('currency_rs'),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.kprimaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        context.tr('application_rate'),
                        style: Styles.textStyle12,
                      ),
                    ),
                    Gap(context.responsiveHeight(16)),

                    /// 7. عدد الحضور (Dropdown)
                    CustomDropdownFormField<String>(
                      hint: context.tr('attendees_count'),
                      items: [
                        DropdownMenuItem(
                          value: '2000',
                          child: Text('2000', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '3000',
                          child: Text('3000', style: Styles.textStyle14),
                        ),
                        DropdownMenuItem(
                          value: '10000',
                          child: Text('10000', style: Styles.textStyle14),
                        ),
                      ],

                      onChanged: (val) => eventsCubit.numberOfffAttendees(val),
                      validator: (value) =>
                          value == null ? context.tr('required') : null,
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
                    ),

                    Gap(context.responsiveHeight(16)),

                    BlocBuilder<EventsCubit, EventsState>(
                      builder: (context, state) {
                        final images = state.pickedImages;
                        if (images.isEmpty) return const SizedBox.shrink();
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
                                    height: context.responsiveHeight(150),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF70C1B3),
                                      ),
                                      color: const Color(0xFFEFFFFC),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
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
                                        eventsCubit.removePickedImageAt(index);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
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
                        final video = await _videoPicker.pickFromGallery();
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

                        style: Styles.textStyle12.copyWith(color: Colors.grey),
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
                      title: context.tr('create_event_btn'),
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
        ],
      ),
    );
  }
}
