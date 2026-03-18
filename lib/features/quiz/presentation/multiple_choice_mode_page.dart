import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class MultipleChoiceModePage extends StatefulWidget {
  const MultipleChoiceModePage({super.key});

  @override
  State<MultipleChoiceModePage> createState() => _MultipleChoiceModePageState();
}

class _MultipleChoiceModePageState extends State<MultipleChoiceModePage> {
  bool isTimerEnabled = true;
  int selectedTime = 20;
  int numberOfQuestions = 0;
  final TextEditingController _questionsController = TextEditingController(text: "0");
  late Deck deck;
  bool _initialized = false;

  String? _errorMessage;

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFE3F2FD);
  static const Color accentColor = Color(0xFF2196F3);
  static const Color actionblue = Color(0xFF00B0FF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;

    numberOfQuestions = deck.totalCards;
    _questionsController.text = '$numberOfQuestions';
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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size:28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // PINALITAN: Inalis ang logo, pinalitan ng text ng napiling mode
        title: const Text(
          "Multiple Choice",
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
            // TINANGGAL: Ang "SELECTED MODE" Container card dito ay inalis na.

            // Question Input Section
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
                  const Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: primaryColor, size: 24),
                      SizedBox(width: 8),
                      Text("Number of Questions",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max: ${deck.totalCards} cards available',
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
                        if (parsed > deck.totalCards) {
                          _errorMessage = "Maximum is ${deck.totalCards} questions only.";
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
                        borderSide: const BorderSide(color: accentColor, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: primaryColor, width: 2.0),
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
                        color: _errorMessage == null ? primaryColor : Colors.red),
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
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: primaryColor, size: 24),
                          SizedBox(width: 8),
                          Text("Quiz Timer",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) => setState(() => isTimerEnabled = val),
                        activeThumbColor: primaryColor,
                        activeColor: accentColor.withValues(alpha: 0.3),
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
                    )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quiz Summary Section
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
                  const Text("QUIZ SUMMARY",
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  const Row(
                    children: [
                      Icon(Icons.edit_document, color: actionblue, size: 28),
                      SizedBox(width: 10),
                      Text("Multiple Choice",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered, color: primaryColor, size: 28),
                      const SizedBox(width: 10),
                      Text("$numberOfQuestions Questions",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive,
                          color: primaryColor, size: 28),
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
                        Navigator.pushNamed(context, 'multiple_choice', arguments: {
                          'numberOfQuestions': numberOfQuestions,
                          'timerMinutes': isTimerEnabled ? selectedTime : null
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionblue,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
                ),
                child: const Text("Start Quiz!",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}