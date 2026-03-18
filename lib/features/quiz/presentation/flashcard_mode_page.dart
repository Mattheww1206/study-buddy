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

  // Blue 60-30-10 Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%

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
      setState(() => _isFinished = true);
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
        deckSubject: _deck.subject,
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
        backgroundColor: secondaryColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(_deck.title, style: const TextStyle(color: Colors.white)),
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
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true, 
        titleSpacing: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _deck.title,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          ),
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
                          color: primaryColor)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                ],
              ),
              
              const SizedBox(height: 30),

              // Flashcard Section
              Expanded(
                child: _isFinished || _isSaving
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : Dismissible(
                        key: ValueKey(_currentIndex),
                        onDismissed: _onSwipe,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.check_circle,
                              color: Colors.green, size: 60),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.cancel,
                              color: Colors.red, size: 60),
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
                                        : primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                          color: primaryColor.withOpacity(0.2),
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
                                                        fontSize: 24,
                                                        color: Color(0xFF2D3142),
                                                        height: 1.5),
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
                                                          letterSpacing: 1.1)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 30),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      card.question,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 30,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      child: const Text(
                                                        'Tap to flip',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                          : primaryColor.withOpacity(0.15),
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