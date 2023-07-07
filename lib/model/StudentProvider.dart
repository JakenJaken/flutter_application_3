import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StudentProvider with ChangeNotifier {
  List<dynamic> students = [];
  String token = '';

  Future<void> fetchData(String token) async {
    this.token = token;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        students = responseData;
        notifyListeners();
      } else {
        print('Failed to fetch students. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while fetching students: $e');
    }
  }

  Future<void> addStudent(String name, int age, File? profilePicture) async {
    try {
      final url = Uri.parse('http://localhost:8000/api/students');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['student_name'] = name;
      request.fields['student_age'] = age.toString();
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
        ));
      }

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Student added successfully
        fetchData(token); // Refresh the student list
      } else {
        print(
            'Failed to add student. Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Exception occurred while adding student: $e');
    }
  }

  Future<void> updateStudent(
      int studentId, String name, int age, File? profilePicture) async {
    try {
      final url = Uri.parse('http://localhost:8000/api/students/$studentId');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['student_name'] = name;
      request.fields['student_age'] = age.toString();
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
        ));
      }

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Student updated successfully
        fetchData(token); // Refresh the student list
      } else {
        print(
            'Failed to update student. Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Exception occurred while updating student: $e');
    }
  }

  Future<void> deleteStudent(int studentId) async {
    try {
      final url = Uri.parse('http://localhost:8000/api/students/$studentId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Student deleted successfully
        fetchData(token); // Refresh the student list
      } else {
        print('Failed to delete student. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred while deleting student: $e');
    }
  }
}
