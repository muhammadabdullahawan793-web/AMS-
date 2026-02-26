import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'marks_feedback_screen.dart';

class StudentSubmissionsScreen extends StatefulWidget {
  final String assignmentId;

  const StudentSubmissionsScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<StudentSubmissionsScreen> createState() =>
      _StudentSubmissionsScreenState();
}

class _StudentSubmissionsScreenState extends State<StudentSubmissionsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  // ================= FETCH SUBMISSIONS =================
  Future<void> fetchSubmissions() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_submissions.php?assignment_id=${widget.assignmentId}",
        ),
      );

      final data = json.decode(res.body);

      if (data["status"] == true && data["data"] is List) {
        submissions = List<Map<String, dynamic>>.from(data["data"]);
      }
    } catch (e) {
      _msg("Failed to load submissions");
    }

    setState(() => isLoading = false);
  }

  // ================= DOWNLOAD FILE =================
  Future<void> downloadFile(String filePath) async {
    final uri = Uri.parse("https://bugcreators.com/Abdullah/$filePath");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _msg("Unable to download file");
    }
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Submissions"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
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
                            // ===== STUDENT NAME =====
                            Text(
                              s["student_name"] ?? "Unknown Student",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ===== ASSIGNMENT ID =====
                            Text(
                              "Assignment ID: ${s["assignment_id"]}",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),

                            const SizedBox(height: 6),

                            // ===== SUBMITTED AT =====
                            Text(
                              "Submitted At: ${s["submitted_at"]}",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 14),

                            // ===== DOWNLOAD BUTTON =====
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: const Text("Download Submission"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3C72),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => downloadFile(s["file_path"]),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ===== MARKS & FEEDBACK =====
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.grade),
                                label: const Text("Marks & Feedback"),
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
                                      builder: (_) => MarksFeedbackScreen(
                                        submissionId: s["id"].toString(),
                                        studentName: s["student_name"],
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
