import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';

// =========================================================
// 1. MODELS & CONFIGURATION
// =========================================================

/// إعدادات البيزنس لوجيك (ماذا تريد أن تختار؟)
class PickerConfig {
  final bool allowMultiple; // هل مسموح بأكثر من عنصر؟
  final int maxCount; // الحد الأقصى
  final RequestType requestType; // common, image, video

  const PickerConfig({
    this.allowMultiple = false,
    this.maxCount = 1,
    this.requestType = RequestType.common,
  });
}

/// النتيجة النهائية التي ستحصل عليها
class SelectedMedia {
  final File file;
  final AssetType type;
  SelectedMedia(this.file, this.type);
}

// =========================================================
// 2. THE CONTROLLER (PURE LOGIC)
// =========================================================

class MediaPickerController extends ChangeNotifier {
  final PickerConfig config;
  final ImagePicker _picker = ImagePicker();

  // State Variables
  List<AssetEntity> _assets = [];
  final Set<AssetEntity> _selectedAssets = {};

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 60;

  // Getters (عشان الـ UI يقرأ البيانات بس ما يعدلش عليها مباشرة)
  List<AssetEntity> get assets => _assets;
  int get selectedCount => _selectedAssets.length;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Constructor
  MediaPickerController({required this.config}) {
    _init();
  }

  // تهيئة وسحب أول دفعة
  Future<void> _init() async {
    await loadMoreAssets();
  }

  // 1. دالة الباجينيشن (تحميل الصور)
  Future<void> loadMoreAssets() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners(); // تحديث الـ UI ليظهر لودينج

    try {
      // طلب الصلاحية
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // إعداد الفلتر (الترتيب الأحدث أولاً)
      final FilterOptionGroup filterOption = FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
        imageOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      );

      // جلب الألبومات
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: config.requestType,
        onlyAll: true,
        filterOption: filterOption,
      );

      if (albums.isEmpty) {
        _hasMore = false;
      } else {
        // جلب الصور من الألبوم "All"
        final newItems = await albums[0].getAssetListPaged(
          page: _currentPage,
          size: _pageSize,
        );

        if (newItems.isEmpty) {
          _hasMore = false;
        } else {
          _assets.addAll(newItems);
          _currentPage++;
        }
      }
    } catch (e) {
      debugPrint("Error loading assets: $e");
    }

    _isLoading = false;
    notifyListeners(); // تحديث الـ UI لإظهار الصور
  }

  // 2. دالة الاختيار (Toggle Selection)
  // ترجع true إذا تمت العملية بنجاح، وترجع false إذا تجاوز الحد الأقصى
  bool toggleSelection(AssetEntity asset) {
    // سيناريو 1: اختيار فردي
    if (!config.allowMultiple) {
      _selectedAssets.clear();
      _selectedAssets.add(asset);
      notifyListeners();
      return true;
    }

    // سيناريو 2: اختيار متعدد
    if (_selectedAssets.contains(asset)) {
      _selectedAssets.remove(asset);
      notifyListeners();
      return true;
    } else {
      if (_selectedAssets.length < config.maxCount) {
        _selectedAssets.add(asset);
        notifyListeners();
        return true;
      } else {
        // تجاوز الحد الأقصى
        return false;
      }
    }
  }

  // هل هذا العنصر مختار حالياً؟ (مفيد للـ UI عشان يلون المربع)
  bool isSelected(AssetEntity asset) {
    return _selectedAssets.contains(asset);
  }

  // 3. تحويل المختارين إلى ملفات (الخطوة النهائية)
  Future<List<SelectedMedia>> submitSelection() async {
    List<SelectedMedia> result = [];
    for (var asset in _selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        result.add(SelectedMedia(file, asset.type));
      }
    }
    return result;
  }

  // 4. الكاميرا
  Future<SelectedMedia?> pickFromCamera() async {
    try {
      // تحديد نوع الكاميرا بناءً على الإعدادات (فيديو أم صورة)
      // هنا مثال للصورة فقط للتبسيط
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return SelectedMedia(File(photo.path), AssetType.image);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
    return null;
  }
}
