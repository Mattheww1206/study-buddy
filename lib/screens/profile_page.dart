import 'package:flutter/material.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return 
     Center(
       child: CustomButton(
        text: 'Log out',
        backgroundColor: Color.fromARGB(255, 176, 176, 180),
        textColor: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 23,
        width: 140,
        height: 50,
        onTap: () {
          Navigator.pushNamed(context, 'login');
        },
        ),
     );
  }
}