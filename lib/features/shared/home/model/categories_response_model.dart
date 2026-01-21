import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/core/models/pagination_model.dart';

class CategoriesResponseModel {
  bool? success;
  String? message;
  Data? data;

  CategoriesResponseModel({this.success, this.message, this.data});

  CategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<CategoryModel>? categories;
  PaginationModel? pagination;

  Data({this.categories, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <CategoryModel>[];
      json['categories'].forEach((v) {
        categories!.add(CategoryModel.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null;
  }
}