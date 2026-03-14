import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final Function()? onRemove;
  final bool isLoading;
  final int? maxQuantity;

  const QuantitySelectorWidget({
    Key? key,
    required this.quantity,
    required this.onQuantityChanged,
    this.onRemove,
    this.isLoading = false,
    this.maxQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canIncrease = maxQuantity == null || quantity < maxQuantity!;
    final bool canDecrease = quantity > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: canDecrease && !isLoading
              ? () {
                  if (quantity == 1) {
                    onRemove?.call();
                  } else {
                    onQuantityChanged(quantity - 1);
                  }
                }
              : null,
          isEnabled: canDecrease && !isLoading,
          context: context,
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: canIncrease && !isLoading
              ? () => onQuantityChanged(quantity + 1)
              : null,
          isEnabled: canIncrease && !isLoading,
          context: context,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? Colors.black87 : Colors.grey.shade300,
        ),
      ),
    );
  }
}
