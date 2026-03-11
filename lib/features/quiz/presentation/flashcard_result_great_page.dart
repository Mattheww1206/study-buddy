import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardResultGreatPage extends StatefulWidget {
  const FlashcardResultGreatPage({super.key});

  @override
  State<FlashcardResultGreatPage> createState() =>
      _FlashcardResultGreatPageState();
}

class _FlashcardResultGreatPageState
    extends State<FlashcardResultGreatPage> {
  int gotItCount = 0;
  int againCount = 0;
  List<Flashcard> missedCards = [];
  late Deck deck;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    gotItCount = args['easyCount'] as int;
    againCount = args['againCount'] as int;
    missedCards = args['missedCards'] as List<Flashcard>;
    deck = args['deck'] as Deck;
  }

  @override
  Widget build(BuildContext context) {
    final int totalCards = gotItCount + againCount;
    final double accuracyRatio =
        totalCards > 0 ? gotItCount / totalCards : 0.0;
    final int accuracyPercentage = (accuracyRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header
            const Text('Flashcard Mode',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text('${deck.subject} • ${deck.title}',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 30),
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            const Text('Amazing Session!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            Text('You went through all $totalCards cards',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),

            // White card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Stats 
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
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

                      // Accuracy
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F2FF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Accuracy',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('$accuracyPercentage%',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6C63FF))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: accuracyRatio,
                              backgroundColor: Colors.deepPurple[50],
                              color: const Color(0xFF6C63FF),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Study Again button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            'flashcard_mode',
                            arguments: deck,
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Study Again',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF27F21),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Review Missed button, showed only if may missed cards
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
                                  'deck': deck,
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
                                color: Color(0xFF6C63FF)),
                            label: Text('Review Missed ($againCount)',
                                style: const TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3E5F5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30))),
                          ),
                        ),
                      const SizedBox(height: 15),

                      // Back to Home button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Back to Home',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
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