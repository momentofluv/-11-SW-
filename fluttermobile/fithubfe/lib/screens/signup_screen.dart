import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;

  const SignUpScreen({Key? key, required this.onLoginPressed})
      : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/users/signup/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final snackBar = SnackBar(content: Text('가입 성공'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorMessage = json.decode(response.body)['message'];
        final snackBar = SnackBar(content: Text('Error: $errorMessage'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '사용자 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자 이름을 입력해 주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '유효한 이메일 주소가 아닙니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해 주세요';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 최소 8자리 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signup,
                child: Text('회원가입'),
              ),
              TextButton(
                onPressed: widget.onLoginPressed,
                child: Text('계정이 있나요? 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
