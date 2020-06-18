import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.blueAccent[100],
      ),
      home: Body(),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String email;
  String password;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_changeEmail);
    passwordController.addListener(_changePassword);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _changeEmail() {
    email = emailController.text;
  }

  _changePassword() {
    password = passwordController.text;
  }

  signUp() async {
    if (password.length < 6) {
      return SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline),
            Text(
                'Password length must be at least 6 characters! \n Sample email: example@example.com'),
            SizedBox(width: 30),
          ],
        ),
      );
    }
    try {
      FirebaseUser user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user;

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Home(user: user)));
    } catch (e) {
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline),
            Text(e.message),
            SizedBox(width: 30),
          ],
        ),
      );
    }
  }

  Widget button() {
    return FlatButton(
      onPressed: () async {
        try {
          FirebaseUser user = (await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password))
              .user;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Home(user: user)));
        } catch (e) {
          switch (e.code) {
            case "ERROR_USER_NOT_FOUND":
              signUp();
              break;
            default:
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline),
                    Text(e.message),
                    SizedBox(width: 30),
                  ],
                ),
              );
              break;
          }
        }
      },
      child: Text('Get Weather'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Email',
          ),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
          ),
        ),
        button(),
      ]),
    );
  }
}
