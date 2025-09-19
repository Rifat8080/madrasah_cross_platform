import 'package:flutter/material.dart';

class StaffFormScreen extends StatelessWidget {
  final int? staffId;
  
  const StaffFormScreen({super.key, this.staffId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staffId == null ? 'Add Staff' : 'Edit Staff'),
      ),
      body: const Center(
        child: Text('Staff Form Screen - Coming Soon'),
      ),
    );
  }
}
