import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_3/landing_page.dart';
import 'package:flutter_application_3/login_page.dart';
import 'package:flutter_application_3/register_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  HomePage({required this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/students'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          students = responseData;
        });
      } else {
        print('Failed to fetch students. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while fetching students: $e');
    }
  }

  String getProfilePictureUrl(dynamic student) {
    String baseUrl = 'http://localhost:8000';
    String relativeUrl = student['profile_picture'];
    return '$baseUrl$relativeUrl';
  }

  Future<void> _addStudent(
      String name, int age, String profilePicturePath) async {
    try {
      final url = Uri.parse('http://localhost:8000/api/students');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['student_name'] = name;
      request.fields['student_age'] = age.toString();
      if (profilePicturePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicturePath,
        ));
      }

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 201) {
        // Student added successfully
        fetchData(); // Refresh the student list
        setState(() {});
      } else {
        print('Failed to add student. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while adding student: $e');
    }
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    String name = '';
    int age = 0;
    File? profilePicture;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: (value) => age = int.tryParse(value) ?? 0,
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedImage != null) {
                    profilePicture = File(pickedImage.path);
                  }
                },
                child: Text('Upload Profile Picture'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addStudent(name, age, profilePicture?.path ?? '');
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          String imageUrl = getProfilePictureUrl(student);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            title: Text(student['student_name']),
            subtitle: Text('Age: ${student['student_age']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(token: ''),
      },
    );
  }
}
