import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for inputFormatters
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
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Image.asset(
          'assets/studybuddy-logo.png',
          height: 95,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Mode Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF665FBE),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SELECTED MODE",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.shuffle, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Random Mode",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("A mix of different question types",
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Number of Questions Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: Color(0xFF665FBE), size: 24),
                      SizedBox(width: 8),
                      Text("Number of Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          numberOfQuestions = parsed; // trigger error UI
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
                      errorText: _errorMessage, // Displays the red error message
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 2.0),
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
                      color: _errorMessage == null ? const Color(0xFF665FBE) : Colors.red
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
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Color(0xFF2D2D5E), size: 24),
                          SizedBox(width: 8),
                          Text("Quiz Timer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) => setState(() => isTimerEnabled = val),
                        activeThumbColor: const Color(0xFF665FBE),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isTimerEnabled)
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
                                color: isSelected ? const Color(0xFF665FBE) : const Color(0xFFFAEEFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${time}m",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF665FBE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("QUIZ SUMMARY",
                      style: TextStyle(color: Color(0xFF665FBE), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  const Row(
                    children: [
                      Icon(Icons.shuffle, color: Color(0xFFFF7F32), size: 28),
                      SizedBox(width: 10),
                      Text("Random Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered, color: Color(0xFF665FBE), size: 28),
                      const SizedBox(width: 10),
                      Text("$numberOfQuestions Questions", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive, color: const Color(0xFF665FBE), size: 28),
                      const SizedBox(width: 10),
                      Text(isTimerEnabled ? "$selectedTime min" : "No Limit",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                // Disabled if there's an error or question count is 0
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
                  backgroundColor: const Color(0xFFFF7F32),
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