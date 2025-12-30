import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Create your account!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text("Enter your email"),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
            ),

            SizedBox(height: 20),
            Text("Enter your Password"),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'password',
              ),
            ),

            SizedBox(height: 20),
            Text("Confirm your Password"),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'confirm password',
              ),
            ),

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text("Sign up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
