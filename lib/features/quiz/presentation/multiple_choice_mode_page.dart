import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
     deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;

    // converts num of questions to the total cards of the selected deck
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
            // Select Quiz Mode
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
                        child: const Icon(Icons.edit_document, color: Colors.white, size: 26), 
                      ),
                      const SizedBox(width: 16), 
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Multiple Choice",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), 
                            Text("Pick 1 correct answer from 4 options",
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
                  Text('Max: ${deck.totalCards} cards available',
                  style: TextStyle(
                    color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 13), 
                  TextField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() {
                        numberOfQuestions = parsed > deck.totalCards ? deck.totalCards : parsed;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13), 
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), 
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 1.6), 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), 
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 2.0), 
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF665FBE)), 
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), 
            // Timer
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
                        materialTapTargetSize: MaterialTapTargetSize.padded,
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
           // summary
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
                  Row(
                    children: [
                      const Icon(Icons.edit_document, color: Color(0xFFFF7F32), size: 28), 
                      const SizedBox(width: 10), 
                      const Text("Multiple Choice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
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
                onPressed: () {
                  Navigator.pushNamed(context, 'multiple_choice', arguments:  {
                    'numberOfQuestions': numberOfQuestions,
                    'timerMinutes': isTimerEnabled ? selectedTime : null
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
                  elevation: 3, 
                ),
                child: const Text("Start Quiz!",
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