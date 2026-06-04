import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/invoice_scan_result.dart';
import '../../../../core/network/api_client.dart';

class InvoiceScanService {
  final _dio = ApiClient.instance;

  Future<InvoiceScanResult> scanImage(XFile imageFile) async {
    final fileName = imageFile.name;
    final ext = fileName.toLowerCase();
    final isJpeg = ext.endsWith('.jpg') || 
                   ext.endsWith('.jpeg');

    // Leer los bytes de la imagen (funciona de forma nativa tanto en Web como en Móvil)
    final bytes = await imageFile.readAsBytes();

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
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
        // GPT-4o puede tardar hasta 15 segundos
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    return InvoiceScanResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
