import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'student_marks_feedback_screen.dart';

class SubmittedAssignmentsScreen extends StatefulWidget {
  const SubmittedAssignmentsScreen({super.key});

  @override
  State<SubmittedAssignmentsScreen> createState() =>
      _SubmittedAssignmentsScreenState();
}

class _SubmittedAssignmentsScreenState
    extends State<SubmittedAssignmentsScreen> {
  bool isLoading = true;
  List submissions = [];
  String studentId = "";

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  Future<void> loadStudent() async {
    final prefs = await SharedPreferences.getInstance();
    studentId = prefs.getString("user_id") ?? "";
    fetchSubmitted();
  }

  Future<void> fetchSubmitted() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_submitted_assignments.php"
          "?student_id=$studentId",
        ),
      );

      final data = json.decode(res.body);
      if (data["status"] == true) {
        submissions = data["data"];
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted Assignments"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submitted assignments"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final s = submissions[index];

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s["title"],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Assignment ID: ${s["assignment_id"]}",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Submitted At: ${s["submitted_at"]}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.grade),
                                label: const Text("See Marks & Feedback"),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentMarksFeedbackScreen(
                                        title: s["title"],
                                        marks: s["marks"],
                                        feedback: s["feedback"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
