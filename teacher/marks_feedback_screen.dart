import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarksFeedbackScreen extends StatefulWidget {
  final String submissionId;
  final String studentName;

  const MarksFeedbackScreen({
    super.key,
    required this.submissionId,
    required this.studentName,
  });

  @override
  State<MarksFeedbackScreen> createState() => _MarksFeedbackScreenState();
}

class _MarksFeedbackScreenState extends State<MarksFeedbackScreen> {
  final TextEditingController marksCtrl = TextEditingController();
  final TextEditingController feedbackCtrl = TextEditingController();

  bool isLoading = true;
  bool isMarked = false;

  @override
  void initState() {
    super.initState();
    loadExistingMarks();
  }

  // ================= LOAD EXISTING =================
  Future<void> loadExistingMarks() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_submission_detail.php?submission_id=${widget.submissionId}",
        ),
      );

      final data = json.decode(res.body);

      if (data["status"] == true && data["data"] != null) {
        if (data["data"]["marks"] != null) {
          marksCtrl.text = data["data"]["marks"] ?? "";
          feedbackCtrl.text = data["data"]["feedback"] ?? "";
          isMarked = true;
        }
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // ================= SAVE MARKS =================
  Future<void> saveMarks() async {
    if (marksCtrl.text.isEmpty) {
      _msg("Enter marks");
      return;
    }

    final res = await http.post(
      Uri.parse(
        "https://bugcreators.com/Abdullah/api/save_marks_feedback.php",
      ),
      body: {
        "submission_id": widget.submissionId,
        "marks": marksCtrl.text,
        "feedback": feedbackCtrl.text,
      },
    );

    final data = json.decode(res.body);

    if (data["status"] == true) {
      setState(() => isMarked = true);
      _msg("Marked successfully");
    } else {
      _msg("Failed to save");
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marks & Feedback"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student: ${widget.studentName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: marksCtrl,
                    enabled: !isMarked,
                    decoration: const InputDecoration(
                      labelText: "Marks (e.g. 8/10)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackCtrl,
                    enabled: !isMarked,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Feedback",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isMarked ? null : saveMarks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isMarked ? Colors.grey : const Color(0xFF1E3C72),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isMarked ? "Marked ✅" : "Save Marks",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
