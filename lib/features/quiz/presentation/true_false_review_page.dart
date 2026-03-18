import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class TrueFalseReviewPage extends StatefulWidget {
  const TrueFalseReviewPage({super.key});

  @override
  State<TrueFalseReviewPage> createState() => _TrueFalseReviewPageState();
}

class _TrueFalseReviewPageState extends State<TrueFalseReviewPage> {
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;

  // BLUE THEME PALETTE (Consistent sa RandomReviewPage)
  final Color dominantColor = const Color(0xFF1976D2); 
  final Color secondaryColor = const Color(0xFFF5F9FF);
  final Color accentColor = const Color(0xFF2196F3); 
  final Color actionBlue = const Color(0xFF1976D2); 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    wrongAnswers = List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
  }

  // Helper widget para sa consistent look ng answers
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
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review - ${deck.title}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                            // Question Section
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons. rule_rounded,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      item['statement'] ?? '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: dominantColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Answers Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildAnswerBox(
                                    label: 'Your Answer: ',
                                    value: item['selectedAnswer'] ?? '',
                                    icon: Icons.close,
                                    iconColor: Colors.red,
                                    boxColor: const Color(0xFFFFEBEE),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAnswerBox(
                                    label: 'Correct Answer: ',
                                    value: item['correctAnswer'] ?? '',
                                    icon: Icons.check,
                                    iconColor: Colors.green,
                                    boxColor: const Color(0xFFE8F5E9),
                                    valueColor: Colors.green[700],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Footer Status Bar
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              color: accentColor,
                              child: const Text(
                                ' Incorrect',
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