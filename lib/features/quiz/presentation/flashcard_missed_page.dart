import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardMissedPage extends StatefulWidget {
  const FlashcardMissedPage({super.key});

  @override
  State<FlashcardMissedPage> createState() => _FlashcardMissedPageState();
}

class _FlashcardMissedPageState extends State<FlashcardMissedPage> {
  bool _isFlipped = false;
  bool _initialized = false;
  bool _isFinished = false;

  late Deck deck;
  List<Flashcard> missedCards = [];

  int _currentIndex = 0;
  int _gotItCount = 0;
  int _stillUnsureCount = 0;

  // Sky Blue Palette
  static const Color primaryColor = Color(0xFF1976D2);   // Deep Blue
  static const Color backgroundColor = Color(0xFFE3F2FD); // Light Blue
  static const Color progressColor = Color(0xFF2196F3);  // Primary Blue

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    missedCards = args['missedCards'] as List<Flashcard>;
    deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
  }

  void _onSwipe(DismissDirection direction) {
    if (_isFinished) return;

    if (direction == DismissDirection.startToEnd) {
      _gotItCount++;
    } else {
      _stillUnsureCount++;
    }

    final isLastCard = _currentIndex >= missedCards.length - 1;

    if (!isLastCard) {
      setState(() {
        _isFlipped = false;
        _currentIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.microtask(() {
        Navigator.pop(context, {
          'gotItCount': _gotItCount,
          'stillUnsureCount': _stillUnsureCount,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (missedCards.isEmpty) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text('No missed cards to review!')),
      );
    }

    final card = missedCards[_currentIndex];
    final totalCards = missedCards.length;
    final progress = (_currentIndex + 1) / totalCards;
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        // Dito nakalagay ang topic/title ng deck
        title: Text(
          deck.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Progress Bar Section
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / $totalCards',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: progressColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: progressColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Review Badge (Optional: Pwedeng tanggalin kung ayaw ng redundant info)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: const Text(
                  'Reviewing Missed Cards',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Flashcard Section
              Expanded(
                child: _isFinished
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : Dismissible(
                        key: ValueKey(_currentIndex),
                        onDismissed: _onSwipe,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.cancel, color: Colors.red, size: 60),
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _isFlipped = !_isFlipped),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, double val, __) {
                              final isBackSide = val > (pi / 2);
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(val),
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isBackSide ? Colors.white : primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: isBackSide
                                      ? Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()..rotateY(pi),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: SingleChildScrollView(
                                                  padding: const EdgeInsets.all(40),
                                                  child: Text(
                                                    card.answer,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      color: Color(0xFF2D3142),
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: 25,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    'swipe left/right to rate',
                                                    style: TextStyle(
                                                        color: Colors.black26,
                                                        fontSize: 12,
                                                        letterSpacing: 1.1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 30),
                                            child: Text(
                                              card.question,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 30),
              const Text('← Still Unsure | Got it! →',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalCards > 8 ? 8 : totalCards,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == (_currentIndex % 8) ? 24 : 8,
                    decoration: BoxDecoration(
                      color: i <= (_currentIndex % 8)
                          ? primaryColor
                          : primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}