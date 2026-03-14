  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

  class IdentificationModePage extends StatefulWidget {
    const IdentificationModePage({super.key});

    @override
    State<IdentificationModePage> createState() => _IdentificationModePageState();
  }

  class _IdentificationModePageState extends State<IdentificationModePage> {
    late Deck _deck;
    bool _initialized = false;
    bool isTimerEnabled = true;
    int selectedTime = 20;
    int numberOfQuestions = 0;
    late TextEditingController _questionsController;

    final Color dominantColor = const Color(0xFF665FBE);
    final Color accentColor = const Color(0xFFFF7F32);
    final Color secondaryColor = const Color(0xFFFAEEFF);

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    // cap default to deck total
    numberOfQuestions = _deck.totalCards.clamp(1, _deck.totalCards);
    _questionsController =
        TextEditingController(text: numberOfQuestions.toString());
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
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
          onPressed: () => Navigator.pop(context),
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
            // mode banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dominantColor,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECTED MODE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.keyboard,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Identification',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Text('Type the correct answer manually',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // number of questions
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
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
                    'Max: ${_deck.totalCards}', 
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 1;
                      setState(() {
                        numberOfQuestions = parsed.clamp(1, _deck.totalCards);
                      });
                    },
                    decoration: InputDecoration(
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
                    ),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dominantColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // timer
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
                        activeThumbColor: dominantColor,
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
                            onTap: () =>
                                setState(() => selectedTime = time),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? dominantColor
                                    : secondaryColor,
                                borderRadius: BorderRadius.circular(12),
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

            // quiz summary
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
                  Text('QUIZ SUMMARY',
                      style: TextStyle(
                          color: dominantColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Icon(Icons.keyboard, color: accentColor, size: 28),
                      const SizedBox(width: 10),
                      const Text('Identification',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered,
                          color: dominantColor, size: 28),
                      const SizedBox(width: 10),
                      Text('$numberOfQuestions Questions',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                          isTimerEnabled
                              ? Icons.timer
                              : Icons.all_inclusive,
                          color: dominantColor,
                          size: 28),
                      const SizedBox(width: 10),
                      Text(
                          isTimerEnabled
                              ? '$selectedTime min'
                              : 'No Limit',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),

            // start button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'identification',
                    arguments: {
                      'numberOfQuestions': numberOfQuestions,
                      'timerMinutes':
                          isTimerEnabled ? selectedTime : null, 
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
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