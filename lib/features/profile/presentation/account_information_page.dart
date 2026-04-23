import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'dart:convert';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/features/profile/service/profile_service.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFE3F2FD);
  static const Color accentColor = Color(0xFF2196F3);

  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  File? _selectedImage;
  bool _isUploadingPhoto = false;
  bool _isSavingUsername = false;

  void _showDeleteConfirmation() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 15),
              const Text('Delete Account?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 10),
              const Text('Are you sure? This action is permanent.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _authService.deleteAccount(userId);
                        userProvider.clearUser();
                        Navigator.pushNamedAndRemoveUntil(context, 'landing', (_) => false);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, maxHeight: 512, maxWidth: 512);
    if (image == null) return;
    setState(() {
      _selectedImage = File(image.path);
      _isUploadingPhoto = true;
    });
    try {
      final base64String = await _profileService.uploadPhoto(
          userId: Provider.of<UserProvider>(context, listen: false).user!.userId,
          imageFile: File(image.path));
      Provider.of<UserProvider>(context, listen: false).updatePhotoUrl(base64String);
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) return;
    setState(() => _isSavingUsername = true);
    try {
      await _profileService.updateUsername(
          userId: Provider.of<UserProvider>(context, listen: false).user!.userId,
          username: newUsername);
      Provider.of<UserProvider>(context, listen: false).updateUsername(newUsername.trim());
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  void _showEditUsernameDialog(String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: secondaryColor.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: accentColor, width: 2)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveUsername(controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: const Text('Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: secondaryColor,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (photoUrl != null && photoUrl.isNotEmpty
                            ? MemoryImage(base64Decode(photoUrl))
                            : null),
                    child: (photoUrl == null || photoUrl.isEmpty) && _selectedImage == null
                        ? const Icon(Icons.person, size: 50, color: primaryColor)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loggedUser?.username ?? '',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(loggedUser?.email ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        // ITO ANG BINAGO PARA SA "EDIT PHOTO" BUTTON NA MAY ICON
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: secondaryColor, // Light purple/blue background
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_outlined, size: 16, color: primaryColor),
                                const SizedBox(width: 6),
                                _isUploadingPhoto 
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text(
                                  'Edit Photo',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('PROFILE INFORMATION'),
            _buildSectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.person_outline,
                    label: 'Username',
                    value: loggedUser?.username ?? '',
                    onEdit: () => _showEditUsernameDialog(loggedUser?.username ?? ''),
                    isLoading: _isSavingUsername,
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1), indent: 70),
                  _infoTile(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: loggedUser?.email ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('SECURITY'),
            _buildSectionCard(
              padding: EdgeInsets.zero,
              child: _actionTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your login password',
                onTap: () => Navigator.pushNamed(context, 'change_password'),
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('DANGER ZONE'),
            _buildSectionCard(
              padding: EdgeInsets.zero,
              child: _actionTile(
                icon: Icons.delete_outline,
                iconColor: Colors.redAccent,
                iconBg: const Color(0xFFFFEBEE),
                title: 'Delete Account',
                titleColor: Colors.redAccent,
                subtitle: 'Permanently remove all your data',
                onTap: _showDeleteConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.2)),
    );
  }

  Widget _buildSectionCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile(
      {required IconData icon,
      required String label,
      required String value,
      VoidCallback? onEdit,
      bool isLoading = false}) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _iconContainer(icon, accentColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                isLoading
                    ? const SizedBox(
                        width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: primaryColor, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      Color? iconColor,
      Color? iconBg,
      Color? titleColor,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: _iconContainer(icon, iconColor ?? primaryColor, bgColor: iconBg),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _iconContainer(IconData icon, Color color, {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bgColor ?? secondaryColor, borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}