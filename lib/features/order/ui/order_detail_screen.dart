import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/order_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/models/order_model.dart';
import '../../payment/ui/payment_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Brand Colors
  static const Color _accentColor = Color(0xFF1A1A1A); // Clean Black
  static const Color _subtleText = Color(0xFF8E8E93);
  static const Color _dividerColor = Color(0xFFE5E5EA);
  static const Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (authProvider.user?.token != null) {
        orderProvider.setToken(authProvider.user!.token!);
        orderProvider.fetchOrderById(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(orderProvider),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Order Detail',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: _accentColor,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: _backgroundColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _dividerColor, height: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close, size: 22, color: _accentColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
      );
    }

    if (orderProvider.error != null) return _buildErrorState(orderProvider);
    if (orderProvider.selectedOrder == null)
      return const Center(child: Text('Order not found'));

    final order = orderProvider.selectedOrder!;
    return RefreshIndicator(
      color: _accentColor,
      onRefresh: () =>
          orderProvider.fetchOrderById(widget.orderId, forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order),
            const SizedBox(height: 40),
            _buildSectionTitle('Items'),
            _buildOrderItems(order),
            const Divider(height: 64, color: _dividerColor),
            _buildSectionTitle('Shipping Information'),
            _buildShippingContent(order),
            const Divider(height: 64, color: _dividerColor),
            _buildSectionTitle('Payment Summary'),
            _buildOrderSummary(order),
            const SizedBox(height: 48),
            _buildOrderActions(order, orderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _subtleText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.orderNumber.isNotEmpty
              ? '#${order.orderNumber}'
              : '#${order.id.substring(0, 8)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              order.status.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(order.status),
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(order.createdAt),
              style: const TextStyle(color: _subtleText, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.book_outlined,
                        size: 20,
                        color: _subtleText,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Qty: ${item.quantity}',
                    style: const TextStyle(color: _subtleText, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShippingContent(OrderModel order) {
    return Text(
      '${order.shippingAddress.street}\n${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}\n${order.shippingAddress.country}',
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF3A3A3C),
        height: 1.6,
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    return Column(
      children: [
        _buildSummaryLine(
          'Subtotal',
          '\$${order.totalPrice.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 12),
        _buildSummaryLine('Shipping', 'Calculated at next step', isGray: true),
        const SizedBox(height: 12),
        _buildSummaryLine(
          'Total',
          '\$${order.totalPrice.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildSummaryLine(
    String label,
    String value, {
    bool isTotal = false,
    bool isGray = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isGray ? _subtleText : _accentColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: isTotal ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActions(OrderModel order, OrderProvider orderProvider) {
    bool isPending = order.status.toLowerCase() == 'pending';
    bool isUnpaid = order.paymentStatus.toLowerCase() != 'paid';

    if (isPending && isUnpaid) {
      return Column(
        children: [
          _buildButton(
            'Pay Now',
            _accentColor,
            Colors.white,
            () => _payForOrder(order.id),
          ),
          const SizedBox(height: 12),
          _buildButton(
            'Cancel Order',
            Colors.transparent,
            const Color(0xFFFF3B30),
            () => _cancelOrder(order.id, orderProvider),
            isBordered: false,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildButton(
    String text,
    Color bg,
    Color textCol,
    VoidCallback onPressed, {
    bool isBordered = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isBordered
                ? const BorderSide(color: _dividerColor)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFF007AFF); // iOS Blue
      case 'cancelled':
        return const Color(0xFFFF3B30); // iOS Red
      case 'pending':
        return const Color(0xFFFF9500); // iOS Orange
      default:
        return const Color(0xFF34C759); // iOS Green
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildErrorState(OrderProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 40, color: _subtleText),
          const SizedBox(height: 16),
          Text(
            provider.error ?? 'Connection error',
            style: const TextStyle(color: _subtleText),
          ),
          TextButton(
            onPressed: () => provider.fetchOrderById(widget.orderId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _payForOrder(String orderId) async {
    final paid = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentScreen(orderId: orderId)));
    if (paid == true && mounted) {
      context.read<OrderProvider>().fetchOrderById(
        widget.orderId,
        forceRefresh: true,
      );
    }
  }

  Future<void> _cancelOrder(String orderId, OrderProvider orderProvider) async {
    try {
      await orderProvider.cancelOrder(orderId);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order Cancelled')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
