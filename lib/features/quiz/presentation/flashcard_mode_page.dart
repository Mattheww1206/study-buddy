import 'dart:math';
import 'package:flutter/material.dart';

class FlashcardModePage extends StatefulWidget {
  const FlashcardModePage({super.key});

  @override
  State<FlashcardModePage> createState() => _FlashcardModePageState();
}

class _FlashcardModePageState extends State<FlashcardModePage> {
  bool _isFlipped = false;
  int _currentIndex = 1; // Nagsisimula sa unang card
  int _score = 0;        // Dito bibilangin ang "Got it!" (Swipe Right)
  final int _totalCards = 20;

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 30),
              // Progress Section
              Row(
                children: [
                  Text("$_currentIndex / $_totalCards", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF665FBE))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        // Progress bar visual
                        value: _currentIndex / _totalCards,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: const Color(0xFF665FBE),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${((_currentIndex / _totalCards) * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 25),
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF665FBE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Biology • Cell Division", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),

              // THE SWIPEABLE & FLIPPABLE CARD
              Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  // LOGIC PARA SA SCORING AT NAVIGATION
                  setState(() {
                    _isFlipped = false;

                    // 1. I-check kung Swipe Right (Got it!)
                    if (direction == DismissDirection.startToEnd) {
                      _score++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Marked as: Got it!"), duration: Duration(milliseconds: 500))
                      );
                    } else {
                      // Swipe Left (Again)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Marked as: Again"), duration: Duration(milliseconds: 500))
                      );
                    }

                    // 2. Navigation Logic kapag natapos ang deck
                    if (_currentIndex >= _totalCards) {
                      double percentage = (_score / _totalCards);
                      
                      if (percentage >= 0.75) {
                        // 75% pataas (15/20 pataas)
                        Navigator.pushReplacementNamed(context, 'flashcard_result_great');
                      } else {
                        // 74% pababa (14/20 pababa)
                        Navigator.pushReplacementNamed(context, 'flashcard_result_again');
                      }
                    } else {
                      // I-move sa susunod na card
                      _currentIndex++;
                    }
                  });
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  color: Colors.transparent,
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.transparent,
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
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isBackSide ? Colors.white : const Color(0xFF51459E),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: isBackSide 
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: Stack(
                                  children: [
                                    Positioned(top: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(10)), child: const Text("DEFINITION", style: TextStyle(color: Color(0xFF665FBE), fontSize: 10, fontWeight: FontWeight.bold)))),
                                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text("Mitosis", style: TextStyle(color: Color(0xFF665FBE), fontSize: 24, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 10),
                                      Text("A type of cell division where one cell divides into two genetically identical daughter cells.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87)),
                                    ]))),
                                    const Positioned(bottom: 20, right: 20, child: Text("swipe left/right to rate", style: TextStyle(color: Colors.black26, fontSize: 12))),
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Positioned(top: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Text("TERM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                                  const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text("Mitosis", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text("Tap to see definition", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  ])),
                                  const Positioned(bottom: 20, right: 20, child: Text("tap to flip →", style: TextStyle(color: Colors.white54, fontSize: 12))),
                                ],
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),
              // Hint for Swiping
              const Text("← Swipe Left | Swipe Right →", 
                style: TextStyle(color: Color(0xFF665FBE), fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [Container(height: 75, width: 85, decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("X", style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)))), const SizedBox(height: 8), const Text("Again", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
                  Column(children: [Container(height: 75, width: 85, decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(20)), child: const Center(child: Icon(Icons.refresh, color: Colors.orange))), const SizedBox(height: 8), const Text("Hard", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
                  Column(children: [Container(height: 75, width: 85, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("✓", style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)))), const SizedBox(height: 8), const Text("Got it!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                ],
              ),
              const SizedBox(height: 30),
              // Pagination Dots (Visual Only)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), height: 8, width: i == (_currentIndex % 5) ? 20 : 8, decoration: BoxDecoration(color: i <= (_currentIndex % 5) ? const Color(0xFF665FBE) : const Color(0xFF665FBE).withOpacity(0.2), borderRadius: BorderRadius.circular(10))))),
            ],
          ),
        ),
      ),
    );
  }
}