import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  State<ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  @override
  Widget build(BuildContext context) {
    final deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    
    // Blue 60-30-10 Palette
    const Color primaryColor = Color(0xFF1976D2);   // 60% (Dominant)
    const Color secondaryColor = Color(0xFFE3F2FD); // 30% (Background/Support)
    const Color accentColor = Color(0xFF2196F3);    // 10% (Accent/Highlights)

    return Scaffold(
      backgroundColor: secondaryColor, // Ginamit ang 30% background color
      appBar: AppBar(
        backgroundColor: primaryColor, // Ginamit ang 60% primary color
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Study',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),

              // Subject Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: primaryColor, // 60% Blue for the main card
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${deck.totalCards} cards',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        deck.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deck.subject,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 8),
                            Text(
                              'Tap a mode to start studying',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              const Text(
                'Choose Study Mode',
                style: TextStyle(
                  color: primaryColor, // Main title in primary blue
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Flashcard Mode Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'flashcard_mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor, // 30% Blue for icon background
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.style, color: accentColor, size: 30), // 10% Accent icon
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flashcard Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18, 
                                color: primaryColor, 
                              ),
                            ),
                            Text(
                              'Flip cards to study terms',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              // Quiz Mode Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'quiz_mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.stars_rounded, color: accentColor, size: 30),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quiz Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18, 
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'Test yourself with questions',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
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