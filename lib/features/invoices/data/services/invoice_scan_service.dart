import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../models/invoice_scan_result.dart';
import '../../../../core/network/api_client.dart';

class InvoiceScanService {
  final _dio = ApiClient.instance;

  Future<InvoiceScanResult> scanImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final ext = fileName.toLowerCase();
    final isJpeg = ext.endsWith('.jpg') || 
                   ext.endsWith('.jpeg');

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType(
          'image',
          isJpeg ? 'jpeg' : 'png',
        ),
      ),
    });

    final response = await _dio.post(
      '/invoices/scan',
      data: formData,
      options: Options(
        // GPT-4o puede tardar hasta 15 segundos, configuramos 60s
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    return InvoiceScanResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
