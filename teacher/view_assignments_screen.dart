import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_submissions_screen.dart';

class ViewAssignmentsScreen extends StatefulWidget {
  const ViewAssignmentsScreen({super.key});

  @override
  State<ViewAssignmentsScreen> createState() => _ViewAssignmentsScreenState();
}

class _ViewAssignmentsScreenState extends State<ViewAssignmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://bugcreators.com/Abdullah/api/get_assignment_records.php",
        ),
      );

      final data = json.decode(res.body);

      if (data["status"] == true && data["data"] is List) {
        records = List<Map<String, dynamic>>.from(data["data"]);
      }
    } catch (e) {
      _msg("Failed to load assignment records");
    }

    setState(() => isLoading = false);
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignment Records"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No records found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final a = records[index];

                    final total = int.parse(a["total_submissions"].toString());
                    final graded = int.parse(a["graded"].toString());
                    final pending = total - graded;

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
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Due: ${a["due_date"]}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Created: ${a["created_at"]}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _stat("Submitted", total),
                                _stat("Graded", graded),
                                _stat("Pending", pending),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text("View Submissions"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3C72),
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

  Widget _stat(String label, int value) {
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
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
