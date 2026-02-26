import 'package:flutter/material.dart';

class StudentMarksFeedbackScreen extends StatelessWidget {
  final String title;
  final dynamic marks;
  final dynamic feedback;

  const StudentMarksFeedbackScreen({
    super.key,
    required this.title,
    required this.marks,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final bool graded =
        marks != null && feedback != null && marks.toString().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marks & Feedback"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: graded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Marks: $marks",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Feedback:",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(feedback),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "No marks & feedback given yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
