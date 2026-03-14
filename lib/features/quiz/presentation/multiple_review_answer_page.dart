import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class MultipleReviewAnswerPage extends StatefulWidget {
  const MultipleReviewAnswerPage({super.key});

  @override
  State<MultipleReviewAnswerPage> createState() => _MultipleReviewAnswerPageState();
}

class _MultipleReviewAnswerPageState extends State<MultipleReviewAnswerPage> {
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;

  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFF665FBE);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    wrongAnswers = List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review — ${deck.title}', 
          style: TextStyle(
              color: secondaryColor, fontWeight: FontWeight.bold),
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
                          color: dominantColor)),
                  const SizedBox(height: 5),
                  const Text('You got everything right!',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 16)),
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
                        color: dominantColor),
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
                                  const Icon(Icons.cancel,
                                      color: Colors.red, size: 28),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      item['question'] ?? '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: dominantColor),
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
                                      color: const Color(0xFFFDEEFF),
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
                                                  color: dominantColor
                                                      .withValues(alpha: 0.7)),
                                              children: [
                                                const TextSpan(
                                                    text: 'Your Answer: '),
                                                TextSpan(
                                                  text: item['selectedAnswer'] ?? '',
                                                  style: TextStyle(
                                                      color: dominantColor,
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
                                      color: const Color(0xFFF3F2FF),
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
                                                  color: dominantColor
                                                      .withValues(alpha: 0.7)),
                                              children: [
                                                const TextSpan(
                                                    text: 'Correct Answer: '),
                                                TextSpan(
                                                  text: item['correctAnswer'] ?? '',
                                                  style: TextStyle(
                                                      color: accentColor,
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
                              color: accentColor,
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