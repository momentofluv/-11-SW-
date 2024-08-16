import 'dart:convert';
import 'package:fithubfe/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// UserProfile 및 Article 모델 클래스를 임포트합니다.

class UserProfileScreen extends StatefulWidget {
  final int id;

  const UserProfileScreen({super.key, required this.id});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<User> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = fetchUserProfile(widget.id);
  }

  Future<User> fetchUserProfile(int id) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/users/$id/'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<User>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          }

          final userProfile = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username: ${userProfile.username}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Email: ${userProfile.email}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Following:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...userProfile.following.map((f) => Text('User ID: $f')),
                const SizedBox(height: 16),
                const Text(
                  'Followers:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...userProfile.followers.map((f) => Text('$f')),
                const SizedBox(height: 16),
                const Text(
                  'Articles:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...userProfile.articleSet.map((article) => ListTile(
                      title: Text(article.content),
                      subtitle: Text('Created at: ${article.createdAt}'),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Liked Articles:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...userProfile.likeArticles.map((article) => ListTile(
                      title: Text(article.content),
                      subtitle: Text('Created at: ${article.createdAt}'),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
