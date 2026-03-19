import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/order_provider.dart';
import '../data/models/order_model.dart';
import '../../../shared/widgets/global_toast.dart';
import '../../auth/logic/auth_provider.dart';
import '../../payment/ui/payment_screen.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();
  final _country = TextEditingController(text: 'Cambodia');

  @override
  void dispose() {
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (authProvider.user?.token != null) {
        orderProvider.setToken(authProvider.user!.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(_street, 'Street'),
              _buildInput(_city, 'City'),
              _buildInput(_state, 'State'),
              _buildInput(_zip, 'Zip Code'),
              _buildInput(_country, 'Country'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: orderProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C569),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: orderProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Create Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final orderProvider = context.read<OrderProvider>();
    final shippingAddress = ShippingAddressModel(
      street: _street.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      zipCode: _zip.text.trim(),
      country: _country.text.trim(),
    );

    final order = await orderProvider.createOrder(
      shippingAddress,
      context: context,
    );

    if (order != null && mounted) {
      context.showSuccessToast('Order created successfully');
      final paid = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentScreen(orderId: order.id)),
      );
      if (paid == true && mounted) {
        Navigator.pop(context, order);
      }
    } else if (mounted) {
      context.showErrorToast(orderProvider.error ?? 'Failed to create order');
    }
  }
}
