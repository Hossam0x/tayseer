import 'package:tayseer/core/utils/helper/image_picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_time_pic.dart';
import 'package:tayseer/core/widgets/custom_date_picker_field.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_upload_image.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_state.dart';
import 'package:tayseer/my_import.dart';

class UpdateEventBody extends StatefulWidget {
  const UpdateEventBody({super.key});

  @override
  State<UpdateEventBody> createState() => _UpdateEventBodyState();
}

class _UpdateEventBodyState extends State<UpdateEventBody> {
  final _imagePicker = ImagePickerHelper();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventDetailCubit, EventDetailState>(
      listenWhen: (previous, current) =>
          previous.updateEventStatus != current.updateEventStatus,
      listener: (context, state) {
        if (state.updateEventStatus != CubitStates.loading) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state.updateEventStatus == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('succ_update_event'),
              isSuccess: true,
            ),
          );
          context.pop();
          context.read<EventDetailCubit>().fetchEventDetail(state.event!.id);
        } else if (state.updateEventStatus == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ',
              isError: true,
            ),
          );
        } else if (state.updateEventStatus == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CustomloadingApp(),
          );
        }
      },
      child: BlocBuilder<EventDetailCubit, EventDetailState>(
        builder: (context, state) {
          final cubit = context.read<EventDetailCubit>();
          return CustomScrollView(
            slivers: [
              CustomSliverAppBarEvent(
                title: context.tr('edit_event'),
                showBackButton: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      children: [
                        /// 1. العنوان
                        CustomTextFormField(
                          hintText: context.tr('title_events'),
                          controller: cubit.titleController,
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 2. الوصف
                        CustomTextFormField(
                          hintText: context.tr('event_description'),
                          maxLines: 5,
                          controller: cubit.descriptionController,
                        ),
                        Gap(context.responsiveHeight(3)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${cubit.descriptionController.text.length}/250',
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.kGreyColor,
                            ),
                          ),
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 3. التاريخ
                        DatePickerField(
                          validator: (value) =>
                              value == null ? context.tr('required') : null,
                          initialValue: state.eventDate,
                          placeholder: context.tr('event_date'),
                          onDateChanged: (date) => cubit.setEventDate(date!),
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 4. الوقت
                        TimePickerFormField(
                          initialValue: state.startTime,
                          onChanged: (value) => cubit.setStartTime(value!),
                          placeholder: context.tr('start_time'),
                          validator: (value) =>
                              value == null ? context.tr('required') : null,
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 5. المدة
                        CustomDropdownFormField<String>(
                          hint: context.tr('event_duration'),
                          value: state.duration,
                          items: [
                            DropdownMenuItem(value: '', child: Text('')),
                            DropdownMenuItem(
                              value: '15 minutes',
                              child: Text(
                                '15 minutes',
                                style: Styles.textStyle12,
                              ),
                            ),
                            DropdownMenuItem(
                              value: '30 minutes',
                              child: Text(
                                '30 minutes',
                                style: Styles.textStyle12,
                              ),
                            ),
                            DropdownMenuItem(
                              value: '1 hour',
                              child: Text('1 hour', style: Styles.textStyle12),
                            ),
                            DropdownMenuItem(
                              value: '2 hours',
                              child: Text('2 hours', style: Styles.textStyle12),
                            ),
                            DropdownMenuItem(
                              value: '3 hours',
                              child: Text('3 hours', style: Styles.textStyle12),
                            ),
                            DropdownMenuItem(
                              value: '4 hours',
                              child: Text('4 hours', style: Styles.textStyle12),
                            ),
                          ],
                          onChanged: (val) => cubit.setDuration(val),
                          validator: (value) =>
                              value == null ? context.tr('required') : null,
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 6. السعر قبل الخصم
                        CustomTextFormField(
                          isNumber: true,
                          controller: cubit.priceBeforeDiscountController,
                          hintText: context.tr('event_price_before_discount'),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('currency_rs'),
                                style: Styles.textStyle14.copyWith(
                                  color: AppColors.kprimaryColor.withOpacity(
                                    0.5,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 7. السعر بعد الخصم
                        CustomTextFormField(
                          isNumber: true,
                          controller: cubit.priceAfterDiscountController,
                          hintText: context.tr('event_price_after_discount'),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('currency_rs'),
                                style: Styles.textStyle14.copyWith(
                                  color: AppColors.kprimaryColor.withOpacity(
                                    0.5,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Gap(context.responsiveHeight(16)),

                        /// 8. عدد الحضور
                        CustomDropdownFormField<String>(
                          hint: context.tr('attendees_count'),
                          value: state.numberOfAttendees,
                          items: [
                            DropdownMenuItem(
                              value: '2000',
                              child: Text('2000', style: Styles.textStyle12),
                            ),
                            DropdownMenuItem(
                              value: '3000',
                              child: Text('3000', style: Styles.textStyle12),
                            ),
                            DropdownMenuItem(
                              value: '10000',
                              child: Text('10000', style: Styles.textStyle12),
                            ),
                          ],
                          onChanged: (val) => cubit.setNumberOfAttendees(val),
                          validator: (value) =>
                              value == null ? context.tr('required') : null,
                        ),
                        Gap(context.responsiveHeight(24)),

                        /// 9. رفع صور جديدة
                        CustomUploadContainer(
                          icon: Icons.camera_alt,
                          title: context.tr('add_event_image'),
                          subtitle: context.tr('add_image_hint'),
                          onTap: () async {
                            final images = await _imagePicker
                                .pickMultipleFromGallery();
                            if (images != null && images.isNotEmpty) {
                              cubit.addPickedImages(images);
                            }
                          },
                        ),
                        Gap(context.responsiveHeight(16)),

                        /// 10. عرض الصور الموجودة مسبقاً (من السيرفر)
                        if (state.existingImages.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'الصور الحالية',
                              style: Styles.textStyle14.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Gap(context.responsiveHeight(8)),
                          SizedBox(
                            height: context.responsiveHeight(150),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.existingImages.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final imageUrl = state.existingImages[index];
                                return _buildExistingImageItem(
                                  context,
                                  imageUrl,
                                  index,
                                  cubit,
                                );
                              },
                            ),
                          ),
                          Gap(context.responsiveHeight(16)),
                        ],

                        /// 11. عرض الصور الجديدة المختارة
                        if (state.pickedImages.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'صور جديدة',
                              style: Styles.textStyle14.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Gap(context.responsiveHeight(8)),
                          SizedBox(
                            height: context.responsiveHeight(150),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.pickedImages.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final img = state.pickedImages[index];
                                return _buildNewImageItem(
                                  context,
                                  img,
                                  index,
                                  cubit,
                                );
                              },
                            ),
                          ),
                        ],

                        Gap(context.responsiveHeight(40)),

                        /// 12. زر الحفظ
                        CustomBotton(
                          useGradient: true,
                          title: context.tr('save'),
                          onPressed: () => cubit.updateEvent(),
                        ),
                        Gap(context.responsiveHeight(20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExistingImageItem(
    BuildContext context,
    String imageUrl,
    int index,
    EventDetailCubit cubit,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: context.responsiveWidth(120),
          height: context.responsiveHeight(150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF70C1B3)),
            color: const Color(0xFFEFFFFC),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => cubit.removeExistingImageAt(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageItem(
    BuildContext context,
    XFile img,
    int index,
    EventDetailCubit cubit,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: context.responsiveWidth(120),
          height: context.responsiveHeight(150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF70C1B3)),
            color: const Color(0xFFEFFFFC),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(img.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => cubit.removePickedImageAt(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
