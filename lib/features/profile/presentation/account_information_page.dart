import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/features/profile/service/profile_service.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  File? _selectedImage;
  bool _isUploadingPhoto = false;
  bool _isSavingUsername = false;
  
  // Delete Confirmation of account
  void _showDeleteConfirmation() {
     final userProvider = Provider.of<UserProvider>(context, listen: false);
     final userId = userProvider.user!.userId;
     final messenger = ScaffoldMessenger.of(context);
     final navigator = Navigator.of(context);
     
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
                // Pinalitan ng default TextStyle
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Are you sure you want to delete your account? This action is permanent and all your data will be lost.',
                textAlign: TextAlign.center,
                // Pinalitan ng default TextStyle
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                      // Pinalitan ng default TextStyle
                      child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await _authService.deleteAccount(userId);
                          userProvider.clearUser();
                          navigator.pushNamedAndRemoveUntil('landing', (_) => false);
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Failed to Delete Account. Please try again.'))
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      // Pinalitan ng default TextStyle
                      child: Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  // upload ng image
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
      final base64String = await _profileService.uploadPhoto(
        userId: userId, 
        imageFile: File(image.path)
        );
      userProvider.updatePhotoUrl(base64String);

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile photo updated.'))
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to save the photo. Please try again.'))
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }
  // save ng new username
  Future<void> _saveUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSavingUsername = true);

    try {
      await _profileService.updateUsername(
        userId: userId, 
        username: newUsername
        );
      userProvider.updateUsername(newUsername.trim());

      messenger.showSnackBar(
          const SnackBar(content: Text('Username updated.')));
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Failed to update username.')));
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  void _showEditUsernameDialog(String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                'Edit Username',
                textAlign: TextAlign.center,
                // Pinalitan ng default TextStyle
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                // Pinalitan ng default TextStyle
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF665FBE))),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                            color: Color(0xFF665FBE)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      // Pinalitan ng default TextStyle
                      child: Text('Cancel',
                          style: TextStyle(
                              color: const Color(0xFF665FBE),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveUsername(controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF665FBE),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      // Pinalitan ng default TextStyle
                      child: Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  Widget get _defaultAvatar => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        colors: [Color(0xFF90CAF9), Color(0xFFE1F5FE)],
      ),
    ),
    child: const Icon(Icons.person, size: 90, color: Colors.black54),
  );

  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<UserProvider>(context).user; 
    final photoUrl = loggedUser?.photoUrl;

    final Color headerColor = const Color(0xFF514BB0); 
    final cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12), 
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 5), 
        ),
      ],
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor:const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Account',
          // Pinalitan ng default TextStyle
          style: TextStyle(
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
              decoration: cardDecoration, 
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: headerColor, 
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Profile Information',
                      textAlign: TextAlign.left,
                      // Pinalitan ng default TextStyle
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: Colors.white, 
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
                                      ? Image.file(_selectedImage!,
                                          fit: BoxFit.cover)
                                      : (photoUrl != null && photoUrl.isNotEmpty)
                                          ? Image.memory(
                                              base64Decode(photoUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context,
                                                      error, stack) =>
                                                  _defaultAvatar,
                                            )
                                          : _defaultAvatar,
                                ),
                              ),
                              if (_isUploadingPhoto)
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.black.withOpacity(0.4),
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
                            onTap: _isUploadingPhoto
                                ? null
                                : _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isUploadingPhoto
                                    ? Colors.grey
                                    // GINAWANG ORANGE PARA SA EDIT AT UPLOAD
                                    : Colors.orange, 
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (photoUrl != null && photoUrl.isNotEmpty) 
                                        ? Icons.edit 
                                        : Icons.camera_alt,
                                      color: Colors.white, size: 23),
                                  const SizedBox(width: 5),
                                  Text(
                                    (photoUrl != null && photoUrl.isNotEmpty) 
                                        ? 'Edit Photo' 
                                        : 'Upload Photo',
                                      // Pinalitan ng default TextStyle
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Username
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: Colors.grey, width: 0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username',
                              // Pinalitan ng default TextStyle
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600])),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: _isSavingUsername
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        loggedUser?.username ?? '',
                                        // Pinalitan ng default TextStyle
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _isSavingUsername
                                    ? null
                                    : () => _showEditUsernameDialog(
                                        loggedUser?.username ?? ''),
                                child: const Icon(Icons.edit,
                                    size: 18, color: Colors.blue),
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
                          // Pinalitan ng default TextStyle
                          Text('Email', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          const SizedBox(height: 2),
                          Text(
                            loggedUser?.email ?? '',
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
            const SizedBox(height: 25), 
            // SECURITY
            Container(
              decoration: cardDecoration, 
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: headerColor, 
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Text(
                      'Security',
                      // Pinalitan ng default TextStyle
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
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
                        // Pinalitan ng default TextStyle
                        Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25), 

            // Delete Account
            GestureDetector(
              onTap: _showDeleteConfirmation, 
              child: Container(
                decoration: cardDecoration, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: headerColor, 
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28), 
                          const SizedBox(width: 10),
                          Text(
                            'Delete Account',
                            // Pinalitan ng default TextStyle
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 255, 255, 255), 
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      // Pinalitan ng default TextStyle
                      child: Text('This action is permanent and cannot be undone.', style: TextStyle(fontSize: 20, color: Colors.black87)),
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