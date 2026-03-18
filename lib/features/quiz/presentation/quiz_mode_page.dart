import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/quiz/service/quiz_service.dart';

class QuizModePage extends StatefulWidget {
  const QuizModePage({super.key});

  @override
  State<QuizModePage> createState() => _QuizModePageState();
}

class _QuizModePageState extends State<QuizModePage> {
  final QuizService _quizService = QuizService();
  late ConnectivityProvider _connectivityProvider = ConnectivityProvider();
  String selectedType = '';
  bool _isChecking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
  }

  void _navigate() {
    if (selectedType == 'Multiple Mode') {
      Navigator.pushNamed(context, 'multiple_mode');
    } else if (selectedType == 'iden_mode') {
      Navigator.pushNamed(context, 'iden_mode');
    } else if (selectedType == 'tf_mode') {
      Navigator.pushNamed(context, 'tf_mode');
    } else if (selectedType == 'ran_mode') {
      Navigator.pushNamed(context, 'ran_mode');
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Color(0xFF1976D2)), // 60% Blue
            SizedBox(width: 10),
            Text('No Internet'),
          ],
        ),
        content: const Text(
          'This quiz has not been generated yet and it requires an internet '
          'connection for the first time.\n\nPlease connect to the '
          'internet to generate the quiz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    final isOnline = await _connectivityProvider.checkRealInternet();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isOnline) {
      _navigate();
      return;
    }

    if (selectedType == 'ran_mode') {
      final isCached = await _quizService.isRandomQuizCached(deck.deckId);
      if (!mounted) return;
      isCached ? _navigate() : _showNoInternetDialog();
      return;
    }

    final quizType = switch (selectedType) {
      'Multiple Mode' => 'multiple_choice',
      'iden_mode' => 'identification',
      'tf_mode' => 'true_false',
      _ => 'multiple_choice',
    };

    final isCached = await _quizService.isQuizCached(deck.deckId, quizType);
    if (!mounted) return;
    if (isCached) {
      _navigate();
    } else {
      _showNoInternetDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    
    // Injected Blue Palette
    const Color primaryColor = Color(0xFF1976D2);   // 60%
    const Color secondaryColor = Color(0xFFE3F2FD); // 30%
    const Color accentColor = Color(0xFF2196F3);    // 10%

    return Scaffold(
      backgroundColor: secondaryColor, // Secondary background
      appBar: AppBar(
        backgroundColor: primaryColor, // Primary dominant
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              deck.title,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),
            const Text(
              'Choose Quiz Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF120E32)),
            ),
            const SizedBox(height: 20),

            // Multiple Choice
            GestureDetector(
              onTap: () => setState(() => selectedType = (selectedType == 'Multiple Mode') ? '' : 'Multiple Mode'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedType == 'Multiple Mode' ? accentColor : Colors.transparent, // Accent 10%
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFD1D9E6), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.edit_document, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Multiple Choice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Choose 1 correct answer from 4 options', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedType == 'Multiple Mode') const Icon(Icons.check_circle, color: accentColor),
                  ],
                ),
              ),
            ),

            // Identification
            GestureDetector(
              onTap: () => setState(() => selectedType = (selectedType == 'iden_mode') ? '' : 'iden_mode'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedType == 'iden_mode' ? accentColor : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFFFF9DB), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.keyboard, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Type the correct answer yourself', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedType == 'iden_mode') const Icon(Icons.check_circle, color: accentColor),
                  ],
                ),
              ),
            ),

            // True or False
            GestureDetector(
              onTap: () => setState(() => selectedType = (selectedType == 'tf_mode') ? '' : 'tf_mode'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedType == 'tf_mode' ? accentColor : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.rule, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('True or False', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Decide if the statement is correct', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedType == 'tf_mode') const Icon(Icons.check_circle, color: accentColor),
                  ],
                ),
              ),
            ),

            // Random Mix
            GestureDetector(
              onTap: () => setState(() => selectedType = (selectedType == 'ran_mode') ? '' : 'ran_mode'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedType == 'ran_mode' ? accentColor : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.casino, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Random Mix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Mix of all types, randomly shuffled', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedType == 'ran_mode') const Icon(Icons.check_circle, color: accentColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Start Button
            ElevatedButton(
              onPressed: _isChecking || selectedType.isEmpty ? null : _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Start button uses Primary Blue
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
              ),
              child: _isChecking
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Start Quiz',
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}