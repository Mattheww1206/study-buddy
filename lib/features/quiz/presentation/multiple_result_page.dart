import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class MultipleResultPage extends StatefulWidget {
  const MultipleResultPage({super.key});

  @override
  State<MultipleResultPage> createState() => _MultipleResultPageState();
}

class _MultipleResultPageState extends State<MultipleResultPage> {
  int _correctCount = 0;
  int _totalCards = 0;
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;
  String timeUsed = '';
  
  bool _isFirstQuizToday = false;

  // BLUE THEME PALETTE
  final Color primaryColor = const Color(0xFF1976D2);   // 60%
  final Color secondaryColor = const Color(0xFFE3F2FD); // 30%
  final Color accentColor = const Color(0xFF2196F3);    // 10%
  final Color actionBlue = const Color(0xFF00B0FF);     // Action Accent

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // Extraction with safety checks
    _correctCount = args['correctCount'] as int;
    _totalCards = args['totalCards'] as int;
    
    // DITO ANG CRITICAL PART: 
    // Sinisiguro natin na kung null ang 'wrongAnswers', magiging empty list ito para hindi mag-error ang UI.
    if (args['wrongAnswers'] != null) {
      wrongAnswers = List<Map<String, String>>.from(
        (args['wrongAnswers'] as List).map((item) => Map<String, String>.from(item))
      );
    } else {
      wrongAnswers = [];
    }
    
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    timeUsed = args['timeUsed'] as String? ?? '00:00';
    _isFirstQuizToday = args['isFirstQuizToday'] ?? false;

    debugPrint("DEBUG: Wrong Answers Count = ${wrongAnswers.length}");
  }

  @override
  Widget build(BuildContext context) {
    final double accuracy = _totalCards > 0 ? _correctCount / _totalCards : 0.0;
    final int accuracyPercent = (accuracy * 100).toInt();
    final bool isExcellent = accuracy >= 0.75;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor, 
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'QUIZ COMPLETE!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Icon(
                  isExcellent ? Icons.emoji_events : Icons.sentiment_satisfied,
                  size: 45,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$accuracyPercent%',
                style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), 
              ),
              Text(
                isExcellent ? 'Excellent Work! ' : 'Keep Practicing! ',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '📄 Multiple Choice • $_totalCards Questions • ${deck.subject}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Total Score Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$_correctCount/$_totalCards',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                              ),
                              const Text(
                                'TOTAL SCORE',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Accuracy Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.bar_chart_rounded,
                                          color: primaryColor, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Accuracy',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  Text('$accuracyPercent%',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: accuracy,
                                  minHeight: 10,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor: AlwaysStoppedAnimation<Color>(actionBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Row for Time and Streak
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        color: Colors.black26, size: 22),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(timeUsed,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const Text('TIME USED',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black38,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_isFirstQuizToday)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_fire_department,
                                          color: actionBlue, size: 22),
                                      const SizedBox(width: 8),
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('+1 day',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          Text('STREAK',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black38,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Daily Streak Done!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10, color: Colors.black26, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Buttons Section
                        // LALABAS LANG ITO KUNG MAY WRONG ANSWERS
                        if (wrongAnswers.isNotEmpty) ...[
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              'multiple_review',
                              arguments: {
                                'wrongAnswers': wrongAnswers,
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: actionBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 58),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fact_check, size: 20),
                                SizedBox(width: 10),
                                Text('Review Wrong Answers',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              'home',
                              (route) => false,
                              arguments: 2,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 2),
                            minimumSize: const Size(double.infinity, 58),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 20),
                              const SizedBox(width: 10),
                              Text('Back to Study',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}