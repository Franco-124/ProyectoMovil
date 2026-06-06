import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/finance/transaction_scan_result.dart';

class TransactionScanService {
  final Dio _dio;

  TransactionScanService(this._dio);

  Future<TransactionScanResult> scanReceipt({
    required String categoryId,
    required XFile imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final filename = imageFile.name.isNotEmpty ? imageFile.name : 'receipt.jpg';

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'category_id': categoryId,
    });

    final response = await _dio.post(
      '/finance/transactions/scan',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    return TransactionScanResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
