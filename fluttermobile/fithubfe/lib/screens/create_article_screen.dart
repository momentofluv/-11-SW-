import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  _CreateArticleScreenState createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _createArticle() async {
    if (_formKey.currentState?.validate() ?? false) {
      final content = _contentController.text;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/community/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'content': content,
          // 'image': image, // Optional: Add image support if needed
        }),
      );

      if (response.statusCode == 201) {
        const snackBar =
            SnackBar(content: Text('Article created successfully'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context, true);
      } else {
        const snackBar = SnackBar(content: Text('Failed to create article'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Article'),
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
                onPressed: _createArticle,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
