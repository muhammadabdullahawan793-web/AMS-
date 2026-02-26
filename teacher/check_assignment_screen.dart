import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_submissions_screen.dart';

class CheckAssignmentsScreen extends StatefulWidget {
  const CheckAssignmentsScreen({super.key});

  @override
  State<CheckAssignmentsScreen> createState() => _CheckAssignmentsScreenState();
}

class _CheckAssignmentsScreenState extends State<CheckAssignmentsScreen> {
  bool isLoading = true;
  List assignments = [];

  @override
  void initState() {
    super.initState();
    fetchAssignmentStats();
  }

  Future<void> fetchAssignmentStats() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_assignment_stats.php",
        ),
      );

      final data = json.decode(res.body);

      if (data["status"] == true) {
        assignments = data["data"];
      }
    } catch (e) {
      _msg("Failed to load assignments");
    }

    setState(() => isLoading = false);
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Assignments"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text("No assignments found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];

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
                              a["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Due: ${a["due_date"]}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _stat("Students", a["total_students"]),
                                _stat("Submitted", a["submitted"]),
                                _stat("Pending", a["pending"]),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text("View Submissions"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3C72),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentSubmissionsScreen(
                                        assignmentId: a["id"].toString(),
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

  Widget _stat(String title, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
