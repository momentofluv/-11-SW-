import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditArticleScreen extends StatefulWidget {
  final int articleId;

  const EditArticleScreen({super.key, required this.articleId});

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  // 게시물 상세
  Future<void> _fetchArticle() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/community/${widget.articleId}/'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _contentController.text = data['content'];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load article')),
        );
      }
    }
  }

  // 게시물 수정
  Future<void> _updateArticle() async {
    if (_formKey.currentState?.validate() ?? false) {
      final content = _contentController.text;

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/community/${widget.articleId}/'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(<String, String>{
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        const snackBar =
            SnackBar(content: Text('Article updated successfully'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pop(context, true);
        }
      } else {
        const snackBar = SnackBar(content: Text('Failed to update article'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Add the token to the headers
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitHUB',
          style: TextStyle(
            fontFamily: 'logo',
            fontSize: 24, // Example of adding more style properties
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateArticle,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
