import 'dart:convert';
import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String token;
  HomePage({required this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  String error = '';
  TextEditingController name = TextEditingController();

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        students = responseData.map((data) => Student.fromJson(data)).toList();
      });
    } else {
      setState(() {
        error = 'Failed to fetch student data. Error: ${response.statusCode}';
      });
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8000/api/students/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      fetchData();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed to delete student'),
          content: Text('Failed to delete student data.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addStudent(String studentName) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'student_name': studentName}),
    );

    if (response.statusCode == 201) {
      fetchData();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed to add student'),
          content: Text('Failed to add student data.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _updateStudent(int id, String studentName) async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/students/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'student_name': studentName}),
    );

    if (response.statusCode == 200) {
      fetchData();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed to update student'),
          content: Text('Failed to update student data.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(student.profilePicture),
              ),
              title: Text(student.studentName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${student.age}'),
                  Text('GPA: ${student.gpa.toStringAsFixed(2)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Edit Student'),
                                const SizedBox(height: 15),
                                TextFormField(
                                  initialValue: student.studentName,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    student.studentName = value;
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    _updateStudent(
                                        student.id, student.studentName);
                                  },
                                  child: const Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Student'),
                          content: Text(
                            'Are you sure you want to delete this student?',
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                _deleteStudent(student.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Add Student'),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: name,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _addStudent(name.text);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class Student {
  final int id;
  String studentName;
  String profilePicture;
  int age;
  double gpa;

  Student({
    required this.id,
    required this.studentName,
    required this.profilePicture,
    required this.age,
    required this.gpa,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentName: json['name'],
      profilePicture:
          'http://localhost:8000/storage/${json['profile_picture']}',
      age: json['age'],
      gpa: json['gpa'].toDouble(),
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
