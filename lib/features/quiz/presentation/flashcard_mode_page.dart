import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class FlashcardModePage extends StatefulWidget {
  const FlashcardModePage({super.key});

  @override
  State<FlashcardModePage> createState() => _FlashcardModePageState();
}

class _FlashcardModePageState extends State<FlashcardModePage> {
  final DeckService _deckService = DeckService();
  final ResultService _resultService = ResultService();
  late Deck _deck;
  List<Flashcard> _flashcards = [];
  List<Flashcard> _missedCards = [];

  bool _isFlipped = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFinished = false;
  int _currentIndex = 0;
  int _easyCount = 0;
  int _againCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
      _loadFlashcards();
    });
  }

  Future<void> _loadFlashcards() async {
    try {
      final cards = await _deckService.getDeckFlashcards(_deck.deckId);
      cards.shuffle();
      setState(() {
        _flashcards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load flashcards.')),
      );
    }
  }

  void _onSwipe(DismissDirection direction) {
    if (_isFinished) return;

    if (direction == DismissDirection.startToEnd) {
      _easyCount++;
    } else {
      _againCount++;
      _missedCards.add(_flashcards[_currentIndex]);
    }

    final isLastCard = _currentIndex >= _flashcards.length - 1;
    if (!isLastCard) {
      setState(() {
        _isFlipped = false;
        _currentIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.microtask(() => _saveResultAndNavigate());
    }
  }

  Future<void> _saveResultAndNavigate() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final totalCards = _flashcards.length;
    final percentage = _easyCount / totalCards;

    try {
      await _resultService.saveResult(StudyResult(
        resultId: '',
        userId: userId,
        deckId: _deck.deckId,
        deckTitle: _deck.title,
        mode: 'flashcard',
        totalCards: totalCards,
        correctCount: _easyCount,
        easyCount: _easyCount,
        againCount: _againCount,
        completedAt: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('Error saving result: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!mounted) return;

    final args = {
      'easyCount': _easyCount,
      'againCount': _againCount,
      'missedCards': _missedCards,
    };

    if (percentage >= 0.75) {
      Navigator.pushReplacementNamed(context, 'flashcard_result_great', arguments: args);
    } else {
      Navigator.pushReplacementNamed(context, 'flashcard_result_again', arguments: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAEEFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAEEFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF665FBE),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No flashcards in this deck.')),
      );
    }

    final card = _flashcards[_currentIndex];
    final totalCards = _flashcards.length;
    final progress = (_currentIndex + 1) / totalCards;

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

              // Progress bar
              Row(
                children: [
                  Text('${_currentIndex + 1} / $totalCards',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF665FBE))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: const Color(0xFF665FBE),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 25),

              // Deck title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF665FBE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _deck.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
              const SizedBox(height: 30),

              // Flashcard Section
              Expanded(
                // FIXED: Idinagdag ang _isFinished check para mawala ang Dismissible 
                // bago mag-navigate, maiwasan ang "Dismissible widget is still part of the tree" error.
                child: _isFinished || _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : Dismissible(
                        key: ValueKey(_currentIndex),
                        onDismissed: _onSwipe,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check_circle,
                              color: Colors.green, size: 50),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.cancel,
                              color: Colors.red, size: 50),
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _isFlipped = !_isFlipped),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, double val, _) {
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
                                    color: isBackSide
                                        ? Colors.white
                                        : const Color(0xFF51459E),
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
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: SingleChildScrollView(
                                                  padding: const EdgeInsets.all(40),
                                                  child: Text(
                                                    card.answer,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black87,
                                                        height: 1.6),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: 20,
                                                right: 20,
                                                child: Text(
                                                    'swipe left/right to rate',
                                                    style: TextStyle(
                                                        color: Colors.black26,
                                                        fontSize: 12)),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 40),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      card.question,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 32,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      'Tap to see definition',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Positioned(
                                              bottom: 20,
                                              right: 20,
                                              child: Text('tap to flip →',
                                                  style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 15)),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 30),
              const Text('← Again | Got it →',
                  style: TextStyle(
                      color: Color(0xFF665FBE),
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 30),

              // Dot indicators
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