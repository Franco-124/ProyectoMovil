import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/network/api_client.dart';

class InvoiceEmitService {
  final _dio = ApiClient.instance;

  Future<String> downloadInvoicePdf(String invoiceId, String invoiceNumber) async {
    final response = await _dio.get(
      '/invoices/$invoiceId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/factura-$invoiceNumber.pdf';
    await File(filePath).writeAsBytes(response.data as List<int>);
    return filePath;
  }

  Future<void> openInvoicePdf(String invoiceId, String invoiceNumber) async {
    final path = await downloadInvoicePdf(invoiceId, invoiceNumber);
    await OpenFile.open(path);
  }
}
