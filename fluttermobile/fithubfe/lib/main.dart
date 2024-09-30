import 'package:fithubfe/screens/create_article_screen.dart';
import 'package:fithubfe/screens/edit_article_screen.dart';
import 'package:fithubfe/screens/home_screen.dart';
import 'package:fithubfe/screens/login_screen.dart';
import 'package:fithubfe/screens/signup_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/edit_article': (context) => const EditArticleScreen(articleId: 4),
        '/login': (context) => LoginScreen(
              onSignUpPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
            ),
        '/signup': (context) => SignUpScreen(
              onLoginPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        '/home': (context) => const HomeScreen(userId: 12),
        '/create_article': (context) => const CreateArticleScreen(),
        // Define other routes if needed
      },
    );
  }
}
