import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class RandomModePage extends StatefulWidget {
  const RandomModePage({super.key});

  @override
  State<RandomModePage> createState() => _RandomModePageState();
}

class _RandomModePageState extends State<RandomModePage> {
  bool isTimerEnabled = true;
  int selectedTime = 20;
  int numberOfQuestions = 10;
  bool _initialized = false;
  late Deck _deck;

  final TextEditingController _questionsController = TextEditingController();

  // Added for validation
  String? _errorMessage;

  // BLUE THEME PALETTE
  final Color primaryColor = const Color(0xFF1976D2);   // Deep Blue
  final Color secondaryColor = const Color(0xFFE3F2FD); // Very Light Blue
  final Color actionBlue = const Color(0xFF00B0FF);     // Vibrant Blue

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;

    // Initial value setup
    numberOfQuestions = _deck.totalCards;
    _questionsController.text = numberOfQuestions.toString();
  }

  @override
  void dispose() {
    _questionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // PINALITAN: Logo ay pinalitan ng Mode Name para sa consistency
        title: const Text(
          "Random Mode",
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
            // TINANGGAL: Ang banner card sa itaas ay tinanggal.

            // Number of Questions Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      const Text("Number of Questions", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max: ${_deck.totalCards} cards available',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
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
                      color: _errorMessage == null ? primaryColor : Colors.red
                    ),
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
                border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, color: primaryColor, size: 24),
                          const SizedBox(width: 8),
                          const Text("Quiz Timer", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) => setState(() => isTimerEnabled = val),
                        activeTrackColor: actionBlue.withValues(alpha: 0.5),
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                  if (isTimerEnabled) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [10, 15, 20, 25, 30].map((time) {
                          bool isSelected = selectedTime == time;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTime = time),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : secondaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${time}m",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : primaryColor,
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
                  border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("QUIZ SUMMARY",
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Icon(Icons.shuffle, color: actionBlue, size: 28),
                      const SizedBox(width: 10),
                      const Text("Random Mode", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered, color: primaryColor, size: 28),
                      const SizedBox(width: 10),
                      Text("$numberOfQuestions Questions", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive, color: primaryColor, size: 28),
                      const SizedBox(width: 10),
                      Text(isTimerEnabled ? "$selectedTime min" : "No Limit",
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
                  Navigator.pushNamed(context, 'random', 
                  arguments: {
                    'numberOfQuestions': numberOfQuestions,
                    'timerMinutes': isTimerEnabled ? selectedTime : null,
                   },
                  ); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionBlue,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
                ),
                child: const Text("Start Random Quiz!",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}