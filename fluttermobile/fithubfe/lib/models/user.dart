import 'package:fithubfe/models/article.dart';

class User {
  final int id;
  final String email;
  final String username;
  final List<int> following;
  final List<int> followers;
  final bool isExpert;
  final List<Article> articleSet;
  final List<Article> likeArticles;
  final String profileImage;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.following,
    required this.followers,
    required this.articleSet,
    required this.likeArticles,
    required this.isExpert,
    required this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      following: (json['following'] as List<dynamic>?)
              ?.map((item) => item as int)
              .toList() ??
          [],
      followers: (json['followers'] as List<dynamic>?)
              ?.map((item) => item as int)
              .toList() ??
          [],
      articleSet: (json['article_set'] as List<dynamic>?)
              ?.map((article) => Article.fromJson(article))
              .toList() ??
          [],
      likeArticles: (json['like_articles'] as List<dynamic>?)
              ?.map((article) => Article.fromJson(article))
              .toList() ??
          [],
      isExpert: json['is_expert'] as bool,
      profileImage: json['profile_image'] as String? ?? '',
    );
  }

  factory User.empty() {
    return User(
      id: 0,
      email: '',
      username: '',
      following: [],
      followers: [],
      articleSet: [],
      likeArticles: [],
      isExpert: false,
      profileImage: '',
    );
  }
}
