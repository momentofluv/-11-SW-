import 'package:fithubfe/models/user.dart';

class Article {
  final int articleId;
  final String content;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final int likesCount;
  final int commentCount;
  final bool isLikedByUser;

  Article({
    required this.articleId,
    required this.content,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likesCount,
    required this.commentCount,
    required this.isLikedByUser,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id'] as int,
      content: json['content'] as String,
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? User.fromJson(json['user']) : User.empty(),
      likesCount: json['likes_count'] as int,
      commentCount: json['comment_count'] as int,
      isLikedByUser: json['is_liked_by_user'] as bool? ?? false,
    );
  }
}
