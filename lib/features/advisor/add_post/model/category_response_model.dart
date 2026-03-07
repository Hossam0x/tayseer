import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/core/models/pagination_model.dart';

class CategoryResponse {
  final List<CategoryModel> categories;
  final PaginationModel pagination;

  CategoryResponse({required this.categories, required this.pagination});
}
