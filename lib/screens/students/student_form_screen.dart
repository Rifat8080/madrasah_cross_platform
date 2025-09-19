import 'package:flutter/material.dart';

class StudentFormScreen extends StatelessWidget {
  final int? studentId;
  
  const StudentFormScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(studentId == null ? 'Add Student' : 'Edit Student'),
      ),
      body: const Center(
        child: Text('Student Form Screen - Coming Soon'),
      ),
    );
  }
}
