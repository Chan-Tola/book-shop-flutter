import 'package:flutter/material.dart';

class AuthorListScreen extends StatelessWidget {
  const AuthorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authors')),
      body: const Center(child: Text('Author List')),
    );
  }
}
