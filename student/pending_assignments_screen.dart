import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'submit_assignment_screen.dart';

class PendingAssignmentsScreen extends StatefulWidget {
  const PendingAssignmentsScreen({super.key});

  @override
  State<PendingAssignmentsScreen> createState() =>
      _PendingAssignmentsScreenState();
}

class _PendingAssignmentsScreenState extends State<PendingAssignmentsScreen> {
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
    fetchPending();
  }

  // ================= FETCH PENDING =================
  Future<void> fetchPending() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_pending_assignments.php"
          "?student_id=$studentId",
        ),
      );

      final data = json.decode(res.body);
      if (data["status"] == true && data["data"] is List) {
        assignments = List<Map<String, dynamic>>.from(data["data"]);
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // ================= OPEN FILE =================
  Future<void> openFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;
    final uri = Uri.parse("https://bugcreators.com/Abdullah/$filePath");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Assignments"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(
                  child: Text(
                    "No pending assignments 🎉",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];
                    final bool hasFile =
                        a["file_path"] != null && a["file_path"].isNotEmpty;

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
                              a["title"],
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
                                  color: Colors.blueGrey, fontSize: 13),
                            ),

                            const SizedBox(height: 6),

                            // ===== DUE DATE =====
                            Text(
                              "Due: ${a["due_date"]}",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ===== ACTION BUTTONS =====
                            Row(
                              children: [
                                if (hasFile)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.download),
                                      label: const Text("Download"),
                                      onPressed: () => openFile(a["file_path"]),
                                    ),
                                  ),
                                if (hasFile) const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E3C72),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                      ).then((_) => fetchPending());
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
                ),
    );
  }
}
