import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() {
          errorMessage = '用户名或密码错误';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '用户名或密码错误';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '邮箱'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '密码'),
              obscureText: true,
            ),
            if (errorMessage != null) ...[
              SizedBox(height: 16),
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
} 