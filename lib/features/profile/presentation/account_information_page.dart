import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/features/profile/presentation/settings_page.dart';
import 'package:studybuddy/shared/widgets/custom_button.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B70), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Account',
          style: GoogleFonts.lora(
            fontWeight:FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Profile Information',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lora(
                        fontWeight: FontWeight.bold,
                        fontSize: 23, 
                    ),
                    ),
                  ),
                
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          
                            image: _selectedImage != null 
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                ) 
                              : null,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              colors: [Color(0xFF90CAF9), Color(0xFFE1F5FE)],
                            ),
                          ),
                         
                          child: _selectedImage == null 
                            ? const Icon(Icons.person, size: 90, color: Colors.black54)
                            : null,
                        ),
            
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.camera_alt, color: Colors.white, size: 23),
                                SizedBox(width: 5),
                                Text('Edit Photo', 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Full Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Full Name', 
                          style: GoogleFonts.inter(fontSize: 20)),
                        Text(
                          'Matthew Manarang', 
                          style: GoogleFonts.lora(fontSize: 20, 
                          fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Username
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey, 
                          width: 0.5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Username', 
                          style: GoogleFonts.inter(
                            fontSize: 20)),
                        Text(
                          'Matthew', 
                          style: GoogleFonts.lora(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Email
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 15),
                    decoration: const BoxDecoration
                    (border: Border(
                      top: BorderSide(
                        color: Colors.grey, 
                        width: 0.5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email', 
                          style: GoogleFonts.inter(
                            fontSize: 20)),
                        Text(
                          'matthew@gmail.com', 
                          style: GoogleFonts.lora(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                             decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECURITY SECTION 
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 25),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Text(
                      'Security', 
                      style: GoogleFonts.inter(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold)),
                  ),
          
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'change_password');
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline, 
                          color: Colors.blue, 
                          size: 35),
                        const SizedBox(width: 15),
                        Text(
                          'Change Password', 
                          style: GoogleFonts.lora(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios, 
                          color: Colors.black, 
                          size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DELETE ACCOUNT 
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Row(
                      children: [
                        const Icon
                        (Icons.warning_amber_rounded, 
                        color: Colors.red, 
                        size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Account', 
                          style: GoogleFonts.inter(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.red.shade900)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'This action is permanent and cannot be undone.',
                      style: GoogleFonts.lora(
                        fontSize: 20, 
                        color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}