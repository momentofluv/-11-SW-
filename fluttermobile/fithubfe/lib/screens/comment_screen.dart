import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommentScreen extends StatefulWidget {
  final int articleId;

  CommentScreen({required this.articleId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late Future<List<dynamic>> _comments;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = fetchComments();
  }

  Future<List<dynamic>> fetchComments() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:8000/community/${widget.articleId}/comment/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/community/${widget.articleId}/comment/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      _commentController.clear();
      setState(() {
        _comments = fetchComments();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Comment added')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add comment')));
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse(
          'http://127.0.0.1:8000/community/${widget.articleId}/comment/$commentId/'),
    );

    if (response.statusCode == 204) {
      setState(() {
        _comments = fetchComments();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Comment deleted')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete comment')));
    }
  }

  Future<void> _likeComment(int commentId) async {
    final response = await http.post(
      Uri.parse(
          'http://127.0.0.1:8000/community/${widget.articleId}/comment/$commentId/like/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _comments = fetchComments();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Comment liked')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to like comment')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No comments yet'));
                }

                final comments = snapshot.data!;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment['user']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['content']),
                          SizedBox(height: 8.0),
                          if (comment['image'] != null)
                            Image.network(comment['image']),
                          SizedBox(height: 8.0),
                          Text('Updated: ${comment['updated_at']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () => _likeComment(comment['id']),
                          ),
                          Text(comment['likes_count'].toString()),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteComment(comment['id']),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentDetailScreen(
                              commentId: comment['id'],
                              articleId: widget.articleId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentDetailScreen extends StatelessWidget {
  final int commentId;
  final int articleId;

  CommentDetailScreen({required this.commentId, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Detail for Comment ID: $commentId'),
      ),
    );
  }
}