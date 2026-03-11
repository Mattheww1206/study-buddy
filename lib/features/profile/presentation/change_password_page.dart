import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isCurrentRequired = false;
  bool _isNewRequired = false;
  bool _isLengthValid = true;
  bool _isPasswordMatch = true;
  bool _isLoading = false; 

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _showConfirmDialog() {
    setState(() {
      _isCurrentRequired = _currentController.text.isEmpty;
      _isNewRequired = _newController.text.isEmpty;

      if (!_isNewRequired) {
        _isLengthValid = _newController.text.length >= 8 && _newController.text.length <= 16;
      } else {
        _isLengthValid = true; 
      }
      
      _isPasswordMatch = _newController.text == _confirmController.text;
    });

    if (_isCurrentRequired || _isNewRequired || !_isLengthValid || !_isPasswordMatch) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white, 
          title: Column(
            children: [
              const Icon(
                Icons.lock_reset, 
                size: 50, 
                color: Color(0xFF665FBE)), 
              const SizedBox(height: 10),
              Text(
                'Confirm Change',
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF665FBE)), 
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to change your password? This will be used for your next login.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lora(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF665FBE), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
                _saveNewPassword();
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.lora(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNewPassword() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2)); 
    await prefs.setString('saved_password', _newController.text);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password Saved Successfully!', style: GoogleFonts.lora()),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF), 
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF665FBE), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFFAEEFF)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF665FBE).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Password', 
                    style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF665FBE))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF665FBE).withValues(alpha: 0.1)),
                    ),
                    child: TextFormField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      style: GoogleFonts.lora(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF665FBE)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isCurrentRequired)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text("Current password is required", style: GoogleFonts.lora(color: Colors.red, fontSize: 11)),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    'New Password', 
                    style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF665FBE))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF665FBE).withValues(alpha: 0.1)),
                    ),
                    child: TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      style: GoogleFonts.lora(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF665FBE)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isNewRequired)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text("New password is required", style: GoogleFonts.lora(color: Colors.red, fontSize: 11)),
                    )
                  else if (!_isLengthValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text("Must be 8-16 characters long", style: GoogleFonts.lora(color: Colors.red, fontSize: 11)),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    'Confirm New Password', 
                    style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF665FBE))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF665FBE).withValues(alpha: 0.1)),
                    ),
                    child: TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: GoogleFonts.lora(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF665FBE)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (!_isPasswordMatch)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text("Passwords do not match", style: GoogleFonts.lora(color: Colors.red, fontSize: 11)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: _isLoading ? null : _showConfirmDialog,
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A01), 
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7A01).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: _isLoading 
                  ? const SizedBox(
                      width: 25, 
                      height: 25, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Update Password',
                      style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}