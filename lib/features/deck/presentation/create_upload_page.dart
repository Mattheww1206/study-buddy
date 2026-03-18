import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';
import 'package:studybuddy/services/file_text_extractor.dart';

class CreateUploadPage extends StatefulWidget {
  const CreateUploadPage({super.key});

  @override
  State<CreateUploadPage> createState() => _CreateUploadPageState();
}

class _CreateUploadPageState extends State<CreateUploadPage> {

  final GeminiService _geminiService = GeminiService();
  final FileTextExtractorService _extractorService = FileTextExtractorService();
  late ConnectivityProvider _connectivityProvider;

  // Blue 60-30-10 Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%
  static const Color colorSuccessIcon = Color(0xFF3CD288);

  PlatformFile? selectedFile;
  bool _isProcessing = false;
  bool _isDone = false;
  String _statusMessage = '';
  bool _hasError = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        _isDone = false;
        _hasError = false;
        _statusMessage = '';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
  }

  Future<void> _processAndGenerate() async {
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;
    final navigator = Navigator.of(context);

    if (selectedFile == null || _isProcessing) return;

    final online = await _connectivityProvider.checkRealInternet();
    if (!online) {
      _showNoInternetDialog();
      return;
    }

    if (userId == null) return;

    setState(() {
      _isProcessing = true;
      _hasError = false;
      _statusMessage = 'Reading file...';
    });
    try {
      final file = File(selectedFile!.path!);
      final extension = selectedFile!.extension ?? '';
      final rawText = await _extractorService.extractText(file, extension);

      if (rawText == null || rawText.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _statusMessage = 'Could not extract text. Please try another file.';
        });
        return;
      }

      final truncatedText = _extractorService.truncateForGemini(rawText);

      setState(() => _statusMessage = 'AI is generating flashcards...');

      final generated = await _geminiService.generateFlashcardsFromText(
        extractedText: truncatedText,
      );

      if (generated == null) {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _statusMessage = 'AI is unavailable. Please try again later.';
        });
        return;
      }

      final title = generated['title']?.toString() ?? 'Uploaded Deck';
      final subject = generated['subject']?.toString() ?? 'General';
      final flashcardsRaw = generated['flashcards'] as List<dynamic>;

      final cards = flashcardsRaw
          .map((f) => {
                'term': f['answer']?.toString() ?? '',
                'def': f['question']?.toString() ?? '',
              })
          .where((c) => c['term']!.isNotEmpty && c['def']!.isNotEmpty)
          .toList();

      setState(() => _statusMessage = 'Saving deck (${cards.length} cards)...');

     final newDeck = await deckProvider.createDeck(
        userId: userId,
        title: title,
        subject: subject,
        cards: cards,
      );

      setState(() {
        _isProcessing = false;
        _isDone = true;
        _statusMessage = 'Done! Created "$title"';
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      deckProvider.selectDeck(newDeck);
      navigator.pushReplacementNamed('create_view');
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _statusMessage = 'Something went wrong.';
      });
    }
  }

  String get _fileSize {
    if (selectedFile == null) return '';
    final bytes = selectedFile!.size;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 10),
            Text('No Internet'),
          ],
        ),
        content: const Text('Connect to the internet to generate flashcards.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor, // 30% background
      appBar: AppBar(
        backgroundColor: primaryColor, // 60% App Bar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isProcessing ? null : () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Upload Document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (_isDone) ...[
                        // Success View
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.description, color: primaryColor, size: 35),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedFile?.name ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '$_fileSize · ${selectedFile?.extension?.toUpperCase() ?? 'FILE'}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle, color: colorSuccessIcon, size: 28),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Upload Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: selectedFile != null ? primaryColor : primaryColor.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: secondaryColor.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  selectedFile != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                                  size: 50,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                selectedFile != null ? selectedFile!.name : 'Upload your file',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap the button below to choose\na file from your device',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 25),
                              ElevatedButton(
                                onPressed: _isProcessing ? null : pickFile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(selectedFile != null ? 'Change File' : 'Choose File'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Supported Formats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ['PDF', 'DOCX', 'DOC']
                              .map((txt) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                                    ),
                                    child: Text(
                                      txt,
                                      style: TextStyle(color: primaryColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hasError ? Colors.red.withValues(alpha: 0.3) : _isDone ? colorSuccessIcon.withValues(alpha: 0.3) : primaryColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isProcessing)
                                const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: primaryColor))
                              else
                                Icon(_hasError ? Icons.error_rounded : Icons.check_circle_rounded, color: _hasError ? Colors.red : colorSuccessIcon, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _statusMessage,
                                  style: TextStyle(fontSize: 14, color: _hasError ? Colors.red : _isDone ? colorSuccessIcon : primaryColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 40),
                      // Main Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: (selectedFile == null || _isProcessing)
                              ? null
                              : _hasError ? pickFile : _processAndGenerate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasError ? Colors.red : accentColor, // 10% accent for action
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isProcessing
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _hasError ? 'Try Again' : selectedFile != null ? 'Generate Flashcards' : 'Choose File',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}