import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/contracts/transaction_repository_contract.dart';
import '../../domain/models/transaction_model.dart';

class TransactionRepository implements TransactionRepositoryContract {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  @override
  Future<Result<List<TransactionModel>>> getAll() async {
    try {
      final response = await apiClient.dio.get('/transactions/');
      final items = (response.data as List).map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(_messageFor(e));
    }
  }

  @override
  Future<Result<TransactionModel>> create(TransactionModel transaction) async {
    try {
      final response = await apiClient.dio.post('/transactions/', data: transaction.toJson());
      return Ok(TransactionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_messageFor(e));
    }
  }

  @override
  Future<Result<TransactionModel>> update(int id, TransactionModel transaction) async {
    try {
      final response = await apiClient.dio.put('/transactions/$id/', data: transaction.toJson());
      return Ok(TransactionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_messageFor(e));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await apiClient.dio.delete('/transactions/$id/');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_messageFor(e));
    }
  }

  @override
  Future<Result<Map<String, double>>> getSummary() async {
    try {
      final response = await apiClient.dio.get('/transactions/summary/');
      final data = response.data as Map<String, dynamic>;
      return Ok({'income': double.parse(data['income'].toString()), 'expense': double.parse(data['expense'].toString()), 'balance': double.parse(data['balance'].toString())});
    } on DioException catch (e) {
      return Err(_messageFor(e));
    }
  }

  String _messageFor(DioException e) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
    }
    if (e.response?.statusCode == 401) {
      return 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
    }
    return 'เกิดข้อผิดพลาด (${e.response?.statusCode ?? "ไม่มีการตอบกลับ"})';
  }
}