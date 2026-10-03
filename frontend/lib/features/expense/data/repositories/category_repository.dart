import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/contracts/category_repository_contract.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_kind.dart';

class CategoryRepository implements CategoryRepositoryContract {
  final ApiClient apiClient;

  CategoryRepository({required this.apiClient});

  @override
  Future<Result<List<CategoryModel>>> getByKind(TransactionKind kind) async {
    try {
      final response = await apiClient.dio.get('/categories/', queryParameters: {'kind': kind.toApi()});
      final items = (response.data as List).map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      return Ok(items);
    } on DioException {
      return const Err('ไม่สามารถโหลดหมวดหมู่ได้');
    }
  }

  @override
  Future<Result<CategoryModel>> create(CategoryModel category) async {
    try {
      final response = await apiClient.dio.post('/categories/', data: category.toJson());
      return Ok(CategoryModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException {
      return const Err('สร้างหมวดหมู่ไม่สำเร็จ');
    }
  }
}