import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../logic/payment_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../shared/widgets/global_toast.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;

  const PaymentScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _cardComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );

      if (authProvider.user?.token != null) {
        paymentProvider.setToken(authProvider.user!.token!);
        await paymentProvider.createPaymentIntent(
          widget.orderId,
          context: context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Stripe card input is not supported on Web in this app. '
              'Run on Android/iOS to test payments.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          final intent = paymentProvider.paymentIntentInfo;

          if (paymentProvider.isLoading && intent == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null && intent == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  paymentProvider.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmount(intent?.amount ?? 0),
                const SizedBox(height: 16),
                _buildCardField(),
                const Spacer(),
                _buildPayButton(paymentProvider, intent?.clientSecret ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmount(int amount) {
    final display = (amount / 100).toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            '\$$display',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Details',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          CardField(
            autofocus: true,
            enablePostalCode: false,
            onCardChanged: (details) {
              setState(() => _cardComplete = details?.complete ?? false);
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Use test card 4242 4242 4242 4242',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(PaymentProvider paymentProvider, String clientSecret) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: paymentProvider.isLoading || !_cardComplete
            ? null
            : () => _handlePay(paymentProvider, clientSecret),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C569),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: paymentProvider.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handlePay(
    PaymentProvider paymentProvider,
    String clientSecret,
  ) async {
    if (clientSecret.isEmpty) {
      context.showErrorToast('Missing payment details');
      return;
    }

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final ok = await paymentProvider.confirmPayment(
        paymentProvider.paymentIntentInfo!.paymentIntentId,
        context: context,
      );

      if (ok && mounted) {
        context.showSuccessToast('Payment successful');
        Navigator.pop(context, true);
      } else if (mounted) {
        context.showErrorToast(
          paymentProvider.error ?? 'Payment confirmation failed',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Payment failed: $e');
      }
    }
  }
}
