import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> assignments = [];
  String studentId = "";

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  // ================= LOAD STUDENT =================
  Future<void> loadStudent() async {
    final prefs = await SharedPreferences.getInstance();
    studentId = prefs.getString("user_id") ?? "";
    fetchAssignments();
  }

  // ================= FETCH ASSIGNMENTS =================
  Future<void> fetchAssignments() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_all_assignments.php",
        ),
      );

      final data = json.decode(res.body);

      if (data["status"] == true && data["data"] is List) {
        assignments = List<Map<String, dynamic>>.from(data["data"]);
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // ================= CHECK SUBMISSION =================
  Future<bool> isSubmitted(String assignmentId) async {
    final res = await http.get(
      Uri.parse(
        "https://bugcreators.com/Abdullah/api/check_submission_status.php"
        "?assignment_id=$assignmentId&student_id=$studentId",
      ),
    );

    final data = json.decode(res.body);
    return data["submitted"] == true;
  }

  // ================= CHECK DUE DATE =================
  bool isDueDatePassed(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return false;
    final due = DateTime.parse(dueDate);
    return DateTime.now().isAfter(due);
  }

  // ================= OPEN FILE =================
  Future<void> openFile(String? path) async {
    if (path == null || path.isEmpty) return;
    final uri = Uri.parse("https://bugcreators.com/Abdullah/$path");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final a = assignments[index];

                final String? filePath = a["file_path"];
                final bool hasFile = filePath != null && filePath.isNotEmpty;
                final bool duePassed = isDueDatePassed(a["due_date"]);

                return FutureBuilder<bool>(
                  future: isSubmitted(a["id"].toString()),
                  builder: (context, snap) {
                    final submitted = snap.data == true;

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
                            // ===== TITLE =====
                            Text(
                              a["title"] ?? "Untitled Assignment",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ===== DESCRIPTION =====
                            Text(a["description"] ?? ""),

                            const SizedBox(height: 8),

                            // ===== TEACHER =====
                            Text(
                              "Teacher: ${a["teacher_name"]}",
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // ===== DUE DATE =====
                            Text(
                              "Due Date: ${a["due_date"] ?? "-"}",
                              style: TextStyle(
                                color: duePassed ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ===== STATUS / ACTIONS =====
                            if (submitted)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      "Submitted",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (duePassed)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.block, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      "Due date has passed",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Row(
                                children: [
                                  if (hasFile)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon:
                                            const Icon(Icons.download_outlined),
                                        label: const Text("Download"),
                                        onPressed: () => openFile(filePath),
                                      ),
                                    ),
                                  if (hasFile) const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1E3C72),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SubmitAssignmentScreen(
                                              assignmentId: a["id"].toString(),
                                            ),
                                          ),
                                        ).then((_) => fetchAssignments());
                                      },
                                      child: const Text("Submit"),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
