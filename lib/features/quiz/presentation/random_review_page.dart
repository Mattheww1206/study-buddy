import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';

class RandomReviewPage extends StatefulWidget {
  const RandomReviewPage({super.key});

  @override
  State<RandomReviewPage> createState() => _RandomReviewPageState();
}

class _RandomReviewPageState extends State<RandomReviewPage> {
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;
 
  final Color dominantColor = Color(0xFF665FBE);
  final Color secondaryColor = Color(0xFFFAEEFF);
  final Color accentColor = Color(0xFF665FBE);
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    wrongAnswers =
        List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = args['deck'] as Deck;
  }
 // Helper widget
  Widget _buildAnswerBox({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color boxColor,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: boxColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    color: dominantColor.withValues(alpha: 0.7)),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                        color: valueColor ?? dominantColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review - ${deck.subject}',
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
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
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: wrongAnswers.length,
                    itemBuilder: (context, index) {
                      final item = wrongAnswers[index];
                      final type = item['type'] ?? 'multiple_choice';

                      final questionText = type == 'true_false'
                          ? item['question'] ?? ''
                          : item['question'] ?? '';

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
                            // Question
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    type == 'multiple_choice'
                                        ? Icons.list_alt
                                        : type == 'identification'
                                            ? Icons.edit_note
                                            : Icons.rule,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      questionText,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: dominantColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Answers
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildAnswerBox(
                                    label: 'Your Answer: ',
                                    value: item['selectedAnswer'] ?? '',
                                    icon: Icons.close,
                                    iconColor: Colors.red,
                                    boxColor: const Color(0xFFFDEEFF),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAnswerBox(
                                    label: 'Correct Answer: ',
                                    value: item['correctAnswer'] ?? '',
                                    icon: Icons.check,
                                    iconColor: Colors.green,
                                    boxColor: const Color(0xFFF3F2FF),
                                    valueColor: Colors.green[700],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Incorrect bar
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