import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardResultGreatPage extends StatefulWidget {
  const FlashcardResultGreatPage({super.key});

  @override
  State<FlashcardResultGreatPage> createState() =>
      _FlashcardResultGreatPageState();
}

class _FlashcardResultGreatPageState extends State<FlashcardResultGreatPage> {
  int gotItCount = 0;
  int againCount = 0;
  List<Flashcard> missedCards = [];
  late Deck deck;
  bool _initialized = false;

  // Blue Theme Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    gotItCount = args['easyCount'] as int;
    againCount = args['againCount'] as int;
    missedCards = args['missedCards'] as List<Flashcard>;
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
  }

  @override
  Widget build(BuildContext context) {
    final int totalCards = gotItCount + againCount;
    final double accuracyRatio =
        totalCards > 0 ? gotItCount / totalCards : 0.0;
    final int accuracyPercentage = (accuracyRatio * 100).toInt();

    // Accuracy Color Logic
    Color accuracyColor = const Color.fromARGB(255, 235, 71, 42); 
    if (accuracyPercentage >= 80) {
      accuracyColor = Colors.green;
    } else if (accuracyPercentage >= 50) {
      accuracyColor = primaryColor;
    }

    return Scaffold(
      backgroundColor: primaryColor, // In-update: Mula purple tungo sa primaryColor
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header: Topic and Subject
            Text(deck.title, 
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(deck.subject, 
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            
            const SizedBox(height: 30),
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            const Text('Amazing Session!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            Text('You went through all $totalCards cards',
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),

            // Main Blue Container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: secondaryColor, // In-update: Mula lavender tungo sa secondaryColor
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Stats Row (Got It and Again)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Text('$gotItCount',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Text('GOT IT!',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Text('$againCount',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Text('AGAIN',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Accuracy Chart Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.bar_chart, color: accentColor), // In-update: accentColor
                                const SizedBox(width: 10),
                                const Text('Accuracy',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text('$accuracyPercentage%',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: accuracyColor)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            LinearProgressIndicator(
                              value: accuracyRatio,
                              backgroundColor: Colors.grey[200],
                              color: accuracyColor,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Study Again Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            'flashcard_mode',
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Study Again',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B0FF), 
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Review Missed Button (Conditional)
                      if (againCount > 0)
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                'flashcard_missed',
                                arguments: {
                                  'missedCards': missedCards,
                                },
                              );
                              if (result != null && mounted) {
                                final map = result as Map<String, dynamic>;
                                setState(() {
                                  final newGotIt = map['gotItCount'] as int;
                                  gotItCount = gotItCount + newGotIt;
                                  againCount = againCount - newGotIt;
                                });
                              }
                            },
                            icon: const Icon(Icons.push_pin,
                                color: primaryColor), // In-update: primaryColor
                            label: Text('Review Missed ($againCount)',
                                style: const TextStyle(
                                    color: primaryColor, // In-update: primaryColor
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(color: primaryColor), // In-update: primaryColor
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30))),
                          ),
                        ),
                      const SizedBox(height: 15),

                      // BACK TO STUDY BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, 
                              'home', 
                              (route) => false,
                              arguments: 2, 
                            );
                          },
                          icon: const Icon(Icons.menu_book, color: Colors.white),
                          label: const Text('Back to Study',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, // In-update: primaryColor
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}