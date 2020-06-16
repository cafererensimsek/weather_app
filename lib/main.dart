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
  bool isSignedUp = false;

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

  Widget signInButton() {
    return FlatButton(
      onPressed: () async {
        try {
          FirebaseUser user = (await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password))
              .user;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Home(user: user)));
        } catch (e) {
          print(e.message);
        }
      },
      child: Text('Sign In'),
    );
  }

  Widget signUpButton() {
    return FlatButton(
      onPressed: () async {
        try {
          FirebaseUser user = (await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password))
              .user;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Home(user: user)));
        } catch (e) {
          print(e.message);
        }
      },
      child: Text('Sign Up'),
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
        signInButton(),
        signUpButton(),
      ]),
    );
  }
}
