import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class TrueFalseModePage extends StatefulWidget {
  const TrueFalseModePage({super.key});

  @override
  State<TrueFalseModePage> createState() => _TrueFalseModePageState();
}

class _TrueFalseModePageState extends State<TrueFalseModePage> {
  late Deck _deck;
  bool _initialized = false;
  bool isTimerEnabled = true;
  int selectedTime = 15;
  int numberOfQuestions = 0;
  late TextEditingController _questionsController;
  String? _errorMessage;

  // BLUE THEME PALETTE
  final Color dominantColor = const Color(0xFF1976D2);   // Solid Primary Blue
  final Color secondaryColor = const Color(0xFFF5F9FF);  // Very Light Blue Background
  final Color accentColor = const Color(0xFF2196F3);     // Action Blue
  final Color actionBlue = const Color(0xFF1976D2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    
    numberOfQuestions = _deck.totalCards;
    _questionsController = TextEditingController(text: numberOfQuestions.toString());
    
    _initialized = true;
  }

  @override
  void dispose() {
    _questionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        // PINALITAN: Text title na ngayon para sa consistency
        title: const Text(
          "True or False",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // TINANGGAL: Ang "Selected Mode" banner container dito.

            // Number of Questions Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: dominantColor.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: dominantColor, size: 24),
                      const SizedBox(width: 8),
                      const Text('Number of Questions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max available: ${_deck.totalCards}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() {
                        if (parsed > _deck.totalCards) {
                          _errorMessage = "Maximum is ${_deck.totalCards} questions only.";
                          numberOfQuestions = parsed; 
                        } else if (parsed <= 0 && val.isNotEmpty) {
                          _errorMessage = "Enter at least 1 question.";
                          numberOfQuestions = 0;
                        } else {
                          _errorMessage = null;
                          numberOfQuestions = parsed;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      errorText: _errorMessage,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: dominantColor, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: dominantColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red, width: 1.6),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _errorMessage == null ? dominantColor : Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timer Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: dominantColor.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              color: dominantColor, size: 24),
                          const SizedBox(width: 8),
                          const Text('Quiz Timer',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) =>
                            setState(() => isTimerEnabled = val),
                        activeColor: Colors.white,
                        activeTrackColor: dominantColor,
                      ),
                    ],
                  ),
                  if (isTimerEnabled) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [5, 10, 15, 20, 30].map((time) {
                          bool isSelected = selectedTime == time;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTime = time),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? dominantColor
                                    : secondaryColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? null 
                                    : Border.all(color: dominantColor.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                '${time}m',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : dominantColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dominantColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUIZ SUMMARY',
                      style: TextStyle(
                          color: dominantColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: accentColor, size: 28),
                      const SizedBox(width: 10),
                      const Text('True or False',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered, color: dominantColor, size: 28),
                      const SizedBox(width: 10),
                      Text('$numberOfQuestions Questions',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive,
                          color: dominantColor, size: 28),
                      const SizedBox(width: 10),
                      Text(isTimerEnabled ? '$selectedTime min' : 'No Limit',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (_errorMessage != null || numberOfQuestions <= 0)
                ? null 
                : () {
                  Navigator.pushNamed(
                    context,
                    'tf', 
                    arguments: {
                      'numberOfQuestions': numberOfQuestions,
                      'timerMinutes': isTimerEnabled ? selectedTime : null,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionBlue,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
                child: const Text('Start Quiz!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}