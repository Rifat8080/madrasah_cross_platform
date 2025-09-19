import 'package:flutter/material.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
      ),
      body: const Center(
        child: Text('Staff List Screen - Coming Soon'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add staff screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
