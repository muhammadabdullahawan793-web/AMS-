import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  File? selectedFile;
  String? fileName;
  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> createAssignment() async {
    if (dueDateController.text.isEmpty) {
      _msg("Due date required");
      return;
    }

    if (selectedFile == null &&
        (titleController.text.isEmpty || descriptionController.text.isEmpty)) {
      _msg("Upload file OR enter title & description");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final teacherId = prefs.getString("user_id");

      if (teacherId == null) throw "Please login again";

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://bugcreators.com/Abdullah/api/create_assignment.php"),
      );

      request.fields["teacher_id"] = teacherId;
      request.fields["due_date"] = dueDateController.text;
      request.fields["title"] = titleController.text;
      request.fields["description"] = descriptionController.text;

      if (selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "assignment_file",
            selectedFile!.path,
          ),
        );
      }

      final response = await request.send();
      final body = await http.Response.fromStream(response);
      final data = json.decode(body.body);

      setState(() => isLoading = false);

      _msg(data["message"]);
      if (data["status"] == true) Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);
      _msg(e.toString());
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Assignment"),
        backgroundColor: const Color(0xFF1E3C72), // Blue theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dueDateController,
              readOnly: true,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );
                if (d != null) {
                  dueDateController.text = "${d.year}-${d.month}-${d.day}";
                }
              },
              decoration: InputDecoration(
                labelText: "Due Date",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(
                fileName != null ? "Change File" : "Upload File",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3C72), // Blue gradient base
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  fileName!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : createAssignment,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor: const Color(0xFF1E3C72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Create Assignment",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
