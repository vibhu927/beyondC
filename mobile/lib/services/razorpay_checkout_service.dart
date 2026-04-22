import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutResult {
  const RazorpayCheckoutResult({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

class RazorpayCheckoutException implements Exception {
  const RazorpayCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RazorpayCheckoutService {
  Future<RazorpayCheckoutResult> openCheckout({
    required String keyId,
    required String orderId,
    required int amountPaise,
    String currency = 'INR',
    required String name,
    required String description,
    String? prefillEmail,
    String? prefillContact,
  }) async {
    final razorpay = Razorpay();
    final completer = Completer<RazorpayCheckoutResult>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse response) {
      if (completer.isCompleted) return;

      final successOrderId = response.orderId;
      final paymentId = response.paymentId;
      final signature = response.signature;

      if (successOrderId == null || paymentId == null || signature == null) {
        completer.completeError(
          const RazorpayCheckoutException(
            'Payment completed but verification fields were missing.',
          ),
        );
        return;
      }

      completer.complete(
        RazorpayCheckoutResult(
          orderId: successOrderId,
          paymentId: paymentId,
          signature: signature,
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
      if (completer.isCompleted) return;
      final message = response.message?.trim();
      completer.completeError(
        RazorpayCheckoutException(
          message?.isNotEmpty == true
              ? message!
              : 'Payment failed or cancelled.',
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse response) {
      if (completer.isCompleted) return;
      final walletName = response.walletName?.trim() ?? 'external wallet';
      completer.completeError(
        RazorpayCheckoutException(
          'Please complete the payment in $walletName and try again.',
        ),
      );
    });

    final options = <String, dynamic>{
      'key': keyId,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'send_sms_hash': true,
      'prefill': {
        if (prefillEmail != null && prefillEmail.trim().isNotEmpty)
          'email': prefillEmail.trim(),
        if (prefillContact != null && prefillContact.trim().isNotEmpty)
          'contact': prefillContact.trim(),
      },
    };

    try {
      razorpay.open(options);
      return await completer.future;
    } catch (error) {
      throw RazorpayCheckoutException(error.toString());
    } finally {
      razorpay.clear();
    }
  }
}
