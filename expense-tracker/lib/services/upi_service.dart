import 'package:url_launcher/url_launcher.dart';

class UpiService {
  // Parse UPI QR code data
  static Map<String, String> parseUpiData(String upiString) {
    Map<String, String> upiData = {};
    
    if (upiString.startsWith('upi://pay?')) {
      String params = upiString.substring(10);
      List<String> paramList = params.split('&');
      
      for (String param in paramList) {
        List<String> keyValue = param.split('=');
        if (keyValue.length == 2) {
          upiData[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
        }
      }
    }
    
    return upiData;
  }

  // Build UPI payment URL
  static String buildUpiUrl({
    required String payeeAddress,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) {
    String url = 'upi://pay?pa=$payeeAddress';
    url += '&pn=${Uri.encodeComponent(payeeName)}';
    url += '&am=${amount.toStringAsFixed(2)}';
    url += '&cu=INR';
    
    if (transactionNote != null && transactionNote.isNotEmpty) {
      url += '&tn=${Uri.encodeComponent(transactionNote)}';
    }
    
    if (transactionRef != null && transactionRef.isNotEmpty) {
      url += '&tr=${Uri.encodeComponent(transactionRef)}';
    }
    
    return url;
  }

  // Launch UPI payment
  static Future<bool> launchUpiPayment(String upiUrl) async {
    try {
      final Uri uri = Uri.parse(upiUrl);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      print('Error launching UPI: $e');
      return false;
    }
  }

  // Complete UPI payment flow
  static Future<bool> initiateUpiPayment({
    required String payeeAddress,
    String? payeeName,
    required double amount,
    String? category,
  }) async {
    final String upiUrl = buildUpiUrl(
      payeeAddress: payeeAddress,
      payeeName: payeeName ?? 'Merchant',
      amount: amount,
      transactionNote: category != null ? '$category expense' : 'Expense',
    );
    
    return await launchUpiPayment(upiUrl);
  }
}
