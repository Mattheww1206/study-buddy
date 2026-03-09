import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardMissedPage extends StatefulWidget {
  const FlashcardMissedPage({super.key});

  @override
  State<FlashcardMissedPage> createState() => _FlashcardMissedPageState();
}

class _FlashcardMissedPageState extends State<FlashcardMissedPage> {
  // Data Source
  final List<Map<String, String>> _cards = [
    {
      "term": "Meiosis",
      "def": "Process where a single cell divides twice to produce four cells."
    },
    {
      "term": "Mitosis",
      "def": "A type of cell division that results in two daughter cells."
    },
    {
      "term": "Cytoplasm",
      "def": "The gelatinous liquid that fills the inside of a cell."
    },
  ];

  bool _isFront = true;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double progressValue = ((_currentIndex + 1) / _cards.length).clamp(0.0, 1.0);

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Text("${_currentIndex + 1} / ${_cards.length}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C5C9D),
                          fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFDCD6F7),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B6B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text("Missed",
                      style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Review Mode Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 16, color: Color(0xFFFF6B6B)),
                    SizedBox(width: 6),
                    Text("Review Mode — Missed Cards",
                        style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- MAIN FLASHCARD WITH DISMISSIBLE SWIPE ---
              Expanded(
                child: Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    setState(() {
                      if (_currentIndex < _cards.length - 1) {
                        _currentIndex++;
                        _isFront = true;
                      } else {
                        _currentIndex = 0; // O i-pop ang page pag tapos na
                      }
                    });
                  },
                  // Green Icon pag swipe pakanan
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                  ),
                  // Red Icon pag swipe pakaliwa
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.cancel, color: Colors.red, size: 50),
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _isFront = !_isFront),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: _isFront ? 0 : pi),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double val, __) {
                        final isBackSide = val > (pi / 2);
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(val),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isBackSide ? Colors.white : const Color(0xFF51459E),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10)
                              ],
                            ),
                            child: isBackSide
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(pi),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: Text(
                                                _cards[_currentIndex]['def']!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 18,
                                                    height: 1.5)),
                                          ),
                                        ),
                                        const Positioned(
                                            bottom: 25,
                                            right: 25,
                                            child: Text("tap to go back to term",
                                                style: TextStyle(
                                                    color: Colors.black26,
                                                    fontSize: 12))),
                                      ],
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      Positioned(
                                          top: 25,
                                          left: 25,
                                          child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                              child: const Text("MISSED • TERM",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.bold)))),
                                      Center(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Text(_cards[_currentIndex]['term']!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 42,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Text("Tap to see definition",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 18))
                                          ])),
                                      const Positioned(
                                          bottom: 25,
                                          right: 25,
                                          child: Text("tap to flip →",
                                              style: TextStyle(
                                                  color: Colors.white54))),
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

              const Center(
                child: Text(
                  "← Still unsure | Got it now! →",
                  style: TextStyle(
                      color: Color(0xFF665FBE),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _cards.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: i == _currentIndex ? 20 : 8,
                    decoration: BoxDecoration(
                      color: i <= _currentIndex
                          ? const Color(0xFF665FBE)
                          : const Color(0xFF665FBE).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}