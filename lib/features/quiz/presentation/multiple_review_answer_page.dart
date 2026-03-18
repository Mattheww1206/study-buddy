import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class MultipleReviewAnswerPage extends StatefulWidget {
  const MultipleReviewAnswerPage({super.key});

  @override
  State<MultipleReviewAnswerPage> createState() => _MultipleReviewAnswerPageState();
}

class _MultipleReviewAnswerPageState extends State<MultipleReviewAnswerPage> {
  final ResultService _resultService = ResultService();
  final AchievementService _achievementService = AchievementService();
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;

  // IN-UPDATE NA COLOR PALETTE (BLUE THEME)
  final Color primaryColor = Color(0xFF1976D2);   // Deep Blue
  final Color secondaryColor = const Color(0xFFE3F2FD); // Very Light Blue
  final Color actionBlue = const Color(0xFF00B0FF);     // Vibrant Blue

  Future<void> _evaluateAchievements() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;
      if (userId == null) return;

      final results = await _resultService.getUserResults(userId);
      final decks = Provider.of<DeckProvider>(context, listen: false).decks;
      final streak = _resultService.calculateStreak(results);

      await _achievementService.evaluateAndUnlock(
        userId: userId,
        results: results,
        decks: decks,
        streak: streak,
        reviewedWrongAnswers: true, 
      );
    } catch (e) {
      print('Achievement eval error: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    wrongAnswers = List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    _evaluateAchievements();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor, // Light blue background
      appBar: AppBar(
        backgroundColor: primaryColor, // Deep blue app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review — ${deck.title}', 
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: wrongAnswers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 10),
                  Text('Perfect Score!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  const SizedBox(height: 5),
                  const Text('You got everything right!',
                      style:
                          TextStyle(color: Colors.black54, fontSize: 16)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    'Wrong Answers (${wrongAnswers.length}):',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: wrongAnswers.length,
                    itemBuilder: (context, index) {
                      final item = wrongAnswers[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // question
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.edit_note, // Icon para sa Identification
                                      color: Colors.orange, size: 28),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      item['question'] ?? '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Column(
                                children: [
                                  // user's answer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.05),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                              children: [
                                                const TextSpan(
                                                    text: 'Your Answer: '),
                                                TextSpan(
                                                  text: item['selectedAnswer'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.close,
                                            color: Colors.red, size: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // correct answer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.05),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                              children: [
                                                const TextSpan(
                                                    text: 'Correct Answer: '),
                                                TextSpan(
                                                  text: item['correctAnswer'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.check,
                                            color: Colors.green,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              color: actionBlue, // Vibrant blue footer
                              child: const Text(
                                'Incorrect',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}