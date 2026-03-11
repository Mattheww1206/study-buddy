import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardMissedPage extends StatefulWidget {
  const FlashcardMissedPage({super.key});

  @override
  State<FlashcardMissedPage> createState() => _FlashcardMissedPageState();
}

class _FlashcardMissedPageState extends State<FlashcardMissedPage> {
  double _dragX = 0;
  bool _isFront = true;
  bool _initialized = false;

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

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    missedCards = args['missedCards'] as List<Flashcard>;
    deck = args['deck'] as Deck;
  }

  void _nextCard() {
    if (_currentIndex >= missedCards.length - 1) {
      Navigator.pop(context, {
        'gotItCount': _gotItCount,
        'stillUnsureCount': _stillUnsureCount,
      });
    } else {
      setState(() {
        _currentIndex++;
        _isFront = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (missedCards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBE6FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No missed cards!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final card = missedCards[_currentIndex];
    final totalCards = missedCards.length;
    final progress = (_currentIndex + 1) / totalCards;

    return Scaffold(
      backgroundColor: const Color(0xFFEBE6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "STUDY BUDDY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  Text("${_currentIndex + 1} / $totalCards",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C5C9D),
                          fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFDCD6F7),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B6B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Missed',
                      style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.push_pin,
                        size: 16, color: Color(0xFFFF6B6B)),
                    const SizedBox(width: 6),
                    Text('Review Mode — ${deck.title}',
                        style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFront = !_isFront),
                  onHorizontalDragUpdate: (details) =>
                      setState(() => _dragX += details.delta.dx),
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;

                    if (_dragX > 80 || velocity > 300) {
                      setState(() => _dragX = 0);
                      _gotItCount++;
                      _nextCard();
                    } else if (_dragX < -80 || velocity < -300) {
                      setState(() => _dragX = 0);
                      _stillUnsureCount++;
                      _nextCard();
                    } else {
                      setState(() => _dragX = 0);
                    }
                  },
                  child: Transform.translate(
                    offset: Offset(_dragX, 0),
                    child: Transform.rotate(
                      angle: _dragX / 1000,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _isFront
                            ? Container(
                                key: const ValueKey(true),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF912C2C),
                                    borderRadius: BorderRadius.circular(35)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Text(card.question,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 42,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey(false),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF5C5C9D),
                                    borderRadius: BorderRadius.circular(35)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(card.answer,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22)),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('← Still unsure',
                      style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold)),
                  Text('swipe', style: TextStyle(color: Colors.grey)),
                  Text('Got it now! →',
                      style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}