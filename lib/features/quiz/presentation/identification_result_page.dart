import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class IdentificationResultPage extends StatefulWidget {
  const IdentificationResultPage({super.key});

  @override
  State<IdentificationResultPage> createState() =>
      _IdentificationResultPageState();
}

class _IdentificationResultPageState extends State<IdentificationResultPage> {
  int _correctCount = 0;
  int _totalCards = 0;
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;
  String timeUsed = '';
  
  // Variable para sa streak visibility
  bool _isFirstQuizToday = false;

  // BAGONG COLOR PALETTE
  static const Color primaryColor = Color(0xFF1976D2);   // 60% (Deep Blue)
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30% (Very Light Blue)
  static const Color accentColor = Color(0xFF2196F3);    // 10% (Medium Blue)
  static const Color actionblue = Color(0xFF00B0FF);     // Action Accent (Vibrant Blue)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _correctCount = args['correctCount'] as int;
    _totalCards = args['totalCards'] as int;
    wrongAnswers =
        List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    timeUsed = args['timeUsed'] as String;
    
    _isFirstQuizToday = args['isFirstQuizToday'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double accuracy =
        _totalCards > 0 ? _correctCount / _totalCards : 0.0;
    final int accuracyPercent = (accuracy * 100).toInt();
    final bool isExcellent = accuracy >= 0.75;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, accentColor], // Deep to Medium Blue gradient
          ),
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
                  isExcellent
                      ? Icons.emoji_events
                      : Icons.sentiment_satisfied,
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
                    color: Colors.white), // Ginawang white para lutang sa blue
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '📝 Identification • $_totalCards Questions • ${deck.subject}',
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
                  decoration: const BoxDecoration(
                    color: secondaryColor, // Light Blue background
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // TOTAL SCORE CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$_correctCount/$_totalCards',
                                style: const TextStyle(
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

                        // ACCURACY CARD
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.insights,
                                          color: primaryColor, size: 20),
                                      SizedBox(width: 8),
                                      Text('Accuracy',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  Text('$accuracyPercent%',
                                      style: const TextStyle(
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
                                  backgroundColor: secondaryColor,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      actionblue), // Vibrant Blue bar
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // TIME AND STREAK ROW
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        color: Colors.black26, size: 22),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(timeUsed,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const Text('TIME USED',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black38,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: _isFirstQuizToday 
                              ? Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.local_fire_department,
                                          color: Colors.orange, size: 22), // Keep orange for fire icon
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('+1 day',
                                            style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                          Text('STREAK',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black38,
                                              fontWeight:FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Daily Streak\nClaimed",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10, 
                                        color: Colors.black26, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        
                        // review wrong answers
                        if (wrongAnswers.isNotEmpty) ...[
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              'iden_review',
                              arguments: {
                                'wrongAnswers': wrongAnswers,
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: actionblue, // Ginamit ang vibrant blue
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
                        
                        // back to home
                        ElevatedButton(
                          onPressed: (){
                            Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false, arguments: 2,);
                          },
                          style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 2),
                        minimumSize: const Size(double.infinity, 58),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 20),
                              SizedBox(width: 10),
                              Text('Back to Study',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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