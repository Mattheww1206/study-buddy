import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardMissedPage extends StatefulWidget {
  const FlashcardMissedPage({super.key});

  @override
  State<FlashcardMissedPage> createState() => _FlashcardMissedPageState();
}

class _FlashcardMissedPageState extends State<FlashcardMissedPage> {
  // Logic states para sa Flip at Swipe
  bool _isFront = true;
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5C5C9D), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFFFB74D),
                    child: Text('🦊', style: TextStyle(fontSize: 35)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 25),

              // Progress Bar
              Row(
                children: [
                  const Text("1 / 3", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C5C9D), fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.33,
                        minHeight: 12,
                        backgroundColor: Color(0xFFDCD6F7),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text("Missed", style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
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
                    Text("Review Mode — Missed Cards", style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- MAIN FLASHCARD (FLIP & SWIPE LOGIC DITO) ---
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFront = !_isFront), // Flip logic
                  onHorizontalDragUpdate: (details) => setState(() => _dragX += details.delta.dx), // Swipe movement
                  onHorizontalDragEnd: (details) {
                    if (_dragX > 100) {
                      print("Swiped Right: Got it!");
                    } else if (_dragX < -100) {
                      print("Swiped Left: Still unsure");
                    }
                    setState(() => _dragX = 0); // Balik sa gitna
                  },
                  child: Transform.translate(
                    offset: Offset(_dragX, 0),
                    child: Transform.rotate(
                      angle: _dragX / 1000,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            builder: (context, childWidget) {
                              final isBack = (ValueKey(_isFront) != child!.key);
                              final value = isBack ? min(rotate.value, pi / 2) : rotate.value;
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(value),
                                alignment: Alignment.center,
                                child: childWidget,
                              );
                            },
                            child: child,
                          );
                        },
                        // Dito nakalagay ang Front at Back UI sa loob ng Switcher
                        child: _isFront 
                          ? Container(
                              key: const ValueKey(true),
                              width: double.infinity,
                              decoration: BoxDecoration(color: const Color(0xFF912C2C), borderRadius: BorderRadius.circular(35)),
                              child: Stack(
                                children: [
                                  Positioned(top: 25, left: 25, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Text("MISSED • TERM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                                  const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Meiosis", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)), Text("You missed this one", style: TextStyle(color: Colors.white70, fontSize: 18))])),
                                  const Positioned(bottom: 25, right: 25, child: Text("tap to flip →", style: TextStyle(color: Colors.white38))),
                                ],
                              ),
                            )
                          : Container(
                              key: const ValueKey(false),
                              width: double.infinity,
                              decoration: BoxDecoration(color: const Color(0xFF5C5C9D), borderRadius: BorderRadius.circular(35)),
                              child: const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Process where a single cell divides twice to produce four cells.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22)))),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Swipe Indicators
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("← Still unsure", style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                  Text("swipe", style: TextStyle(color: Color(0xFF9E9E9E))),
                  Text("Got it now! →", style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),

              // Response Buttons
              Row(
                children: [
                  Expanded(child: Container(height: 85, decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("X\nStill No", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold))))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 85, decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("↺\nGetting it", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFBC02D), fontWeight: FontWeight.bold))))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 85, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("✓\nGot it!", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold))))),
                ],
              ),
              const SizedBox(height: 25),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 25, height: 9, decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(5))),
                  const SizedBox(width: 6),
                  Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFDCD6F7), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFDCD6F7), shape: BoxShape.circle)),
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