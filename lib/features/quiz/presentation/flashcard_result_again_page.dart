import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardResultAgainPage extends StatefulWidget {
  const FlashcardResultAgainPage({super.key});

  @override
  State<FlashcardResultAgainPage> createState() =>
      _FlashcardResultAgainPageState();
}

class _FlashcardResultAgainPageState extends State<FlashcardResultAgainPage> {
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
      backgroundColor: const Color(0xFF43409B),
      body: SafeArea(
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
            const Text('💡', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            const Text('Keep Practicing!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const Text("You'll get better each time",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(children: [
                                Text('$gotItCount',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                const Text('GOT IT!',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
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
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(children: [
                                Text('$againCount',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                const Text('AGAIN',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Accuracy
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF7F6FF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Accuracy',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF43409B))),
                                Text('$accuracyPercentage%',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: accuracyRatio,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFE0E0E0),
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Tip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF7F6FF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 Tip',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF43409B))),
                            const SizedBox(height: 5),
                            Text(
                              'Focus on reviewing the $againCount cards you missed. Try writing the definitions out loud!',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Study Again button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            'flashcard_mode',
                            arguments: deck,
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A3D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Text('🔄 Study Again',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Focus on Missed button
                      if (againCount > 0)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
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
                                final map =
                                    result as Map<String, dynamic>;
                                setState(() {
                                  final newGotIt =
                                      map['gotItCount'] as int;
                                  gotItCount = gotItCount + newGotIt;
                                  againCount = againCount - newGotIt;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF706FD3),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30))),
                            child: Text(
                                '📌 Focus on Missed ($againCount)',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Back to Home button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFFD1C4E9)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30))),
                          child: const Text('← Back to Home',
                              style: TextStyle(
                                  color: Color(0xFF706FD3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
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