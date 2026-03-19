import 'package:flutter/material.dart';

class BookPriceWidget extends StatelessWidget {
  final double? price;

  const BookPriceWidget({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    if (price == null) return const SizedBox.shrink();

    return Text(
      '\$${price!.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 2, 113, 247),
        fontFamily: 'Serif',
      ),
    );
  }
}
