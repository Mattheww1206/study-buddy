import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'dart:convert';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  File? _selectedImage;
  bool _isUploadingPhoto = false;

  // --- START NG DAGDAG: DELETE VALIDATION DIALOG ---
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Delete Account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Are you sure you want to delete your account? This action is permanent and all your data will be lost.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Dito mo ilalagay ang logic para burahin ang account sa Firebase
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing account deletion...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text('Delete', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --- END NG DAGDAG ---

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 256,
      maxWidth: 256,
      imageQuality: 80
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isUploadingPhoto = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'photoUrl': base64String});

      userProvider.updatePhotoUrl(base64String);

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile photo updated.'))
      );
    } catch (e) {
      print('Error saving photo: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to save the photo. Please try again.'))
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit $title',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 18),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1A0B70))),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF1A0B70)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text('Stay', style: GoogleFonts.inter(color: const Color(0xFF1A0B70), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSave(controller.text);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A0B70),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text('Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<UserProvider>(context).user; 
    final photoUrl = loggedUser?.photoUrl;

    // --- Binago: Header color at shadow decoration ---
    final Color headerColor = const Color(0xFF514BB0); // Mas madilim na purple
    final cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12), // Soft shadow
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 5), // Shadow offset sa baba
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor:const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Account',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: cardDecoration, // BINAGO: Shadow added
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: headerColor, // BINAGO: Darker header
                      borderRadius: const BorderRadius.only(
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
                        color: Colors.white, // BINAGO: Puti para mabasa sa dark header
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: _selectedImage != null
                                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                    : photoUrl != null
                                        ? Image.memory(
                                            base64Decode(photoUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) => Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  colors: [Color(0xFF90CAF9), Color(0xFFE1F5FE)],
                                                ),
                                              ),
                                              child: const Icon(Icons.person, size: 90, color: Colors.black54),
                                            ),
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                colors: [Color(0xFF90CAF9), Color(0xFFE1F5FE)],
                                              ),
                                            ),
                                            child: const Icon(Icons.person, size: 90, color: Colors.black54),
                                          ),
                              ),
                            ),
                            if (_isUploadingPhoto)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        GestureDetector(
                          onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isUploadingPhoto ? Colors.grey : Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
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

                  // Username
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loggedUser?.username ?? '',
                                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showEditDialog('Username', loggedUser?.username ?? '', (val) => setState(() => Provider.of<UserProvider>(context, listen: false).updateUsername(val))),
                              child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Email 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text(
                          loggedUser?.emailAdd ?? '',
                          style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25), // Spacing adjusted for shadow

            // SECURITY 
            Container(
              decoration: cardDecoration, // BINAGO: Shadow added
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: headerColor, // BINAGO: Darker header
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Text(
                      'Security',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // BINAGO: White text
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, 'change_password'),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.blue, size: 35),
                        const SizedBox(width: 15),
                        Text('Change Password', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25), // Spacing adjusted for shadow

            // DELETE ACCOUNT SECTION 
            GestureDetector(
              onTap: _showDeleteConfirmation, 
              child: Container(
                decoration: cardDecoration, // BINAGO: Shadow added
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: headerColor, // BINAGO: Darker header
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28), // BINAGO: Lighter red for visibility
                          const SizedBox(width: 10),
                          Text(
                            'Delete Account',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 255, 255, 255), // BINAGO: Light red text
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('This action is permanent and cannot be undone.', style: GoogleFonts.lora(fontSize: 20, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}