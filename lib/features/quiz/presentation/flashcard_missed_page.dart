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
      // Pagkatapos ng huling card, bumalik sa previous screen dala ang results
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
        backgroundColor: Color(0xFFFAEEFF),
        body: Center(child: Text('No missed cards to review!')),
      );
    }

    final card = missedCards[_currentIndex];
    final totalCards = missedCards.length;
    // Calculate progress (0.0 to 1.0)
    final progress = (_currentIndex + 1) / totalCards;
    // Calculate percentage integer
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/studybuddy-logo.png',
          height: 95,
          fit: BoxFit.contain,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Progress Bar Section with Percentage
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / $totalCards',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color.fromARGB(255, 168, 28, 28),
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
                        color:const Color.fromARGB(255, 168, 28, 28), // Kulay pula dahil missed mode
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey, // Muted color gaya ng sa screenshot
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Review Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF912C2C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Review: ${deck.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Flashcard Section
              Expanded(
                child: _isFinished 
                    ? const Center(child: CircularProgressIndicator())
                    : Dismissible(
                        key: ValueKey(_currentIndex),
                        onDismissed: _onSwipe,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.cancel, color: Colors.red, size: 50),
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
                                    color: isBackSide ? Colors.white : const Color(0xFF912C2C),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5)),
                                    ],
                                  ),
                                  child: isBackSide
                                      ? Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()..rotateY(pi),
                                          child: Center(
                                            child: SingleChildScrollView(
                                              padding: const EdgeInsets.all(40),
                                              child: Text(
                                                card.answer,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 18, color: Colors.black87),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: Text(
                                              card.question,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
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
                      color: Color(0xFF665FBE),
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 50),

               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalCards > 5 ? 5 : totalCards,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: i == (_currentIndex % 5) ? 20 : 8,
                    decoration: BoxDecoration(
                      color: i <= (_currentIndex % 5)
                          ? const Color(0xFF665FBE)
                          : const Color(0xFF665FBE).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}