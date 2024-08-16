import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../models/user.dart';
import 'comment_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  List<Article> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/community/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _articles = data.map((item) => Article.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load articles')),
      );
    }
  }

  Future<void> _likeArticle(int articleId, bool isLikedByUser) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/community/$articleId/like/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Refresh articles to reflect the like status
      _fetchArticles(); // Updated method to fetch articles again
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Article liked')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to like article')));
      }
    }
  }

  void _editArticle(int articleId) {
    // Navigate to the edit screen (assumes you have a route for editing)
    Navigator.pushNamed(context, '/edit_article', arguments: articleId)
        .then((result) {
      if (result == true) {
        _fetchArticles(); // Refresh articles after editing
      }
    });
  }

  Future<void> _deleteArticle(int articleId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/community/$articleId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 204) {
      _fetchArticles(); // Refresh articles after deletion
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Article deleted')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete article')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/write.png'),
                      ),
                      title: Text(article.user.username),
                      subtitle: Text(
                          '@${article.user.id} · ${_calculateElapsedTime(article.createdAt)}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editArticle(article.articleId);
                          } else if (value == 'delete') {
                            _deleteArticle(article.articleId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.content),
                          if (article.image != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Image.network(article.image!),
                            ),
                          const SizedBox(height: 10),
                          Text('Updated at: ${_formatDate(article.updatedAt)}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  _showCommentBottomSheet(
                                      context, article.articleId);
                                },
                              ),
                              Text('${article.commentCount}'),
                              IconButton(
                                icon: Icon(
                                  article.isLikedByUser
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      article.isLikedByUser ? Colors.red : null,
                                ),
                                onPressed: () => _likeArticle(
                                    article.articleId, article.isLikedByUser),
                              ),
                              Text('${article.likesCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create_article');
          if (result == true) {
            _fetchArticles(); // 새 게시물이 추가된 후 데이터를 다시 불러옴
          }
        },
        tooltip: 'Create Article',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _calculateElapsedTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    return '${difference.inMinutes}m';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  void _showCommentBottomSheet(BuildContext context, int articleId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return CommentScreen(articleId: articleId);
      },
    );
  }
}
