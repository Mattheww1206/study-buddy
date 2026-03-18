import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';


class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // BLUE THEME PALETTE - 60-30-10 Rule
  static const Color primaryColor = Color(0xFF1976D2);   // 60% (Dominant)
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30% (Background/Large surfaces)
  static const Color accentColor = Color(0xFF2196F3);    // 10% (Action/Highlights)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;
    final deckProvider = context.watch<DeckProvider>();

    if (userId == null) {
      return Scaffold(
        backgroundColor: secondaryColor,
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
            child: const Text('Force Logout', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: secondaryColor, // Ginamit ang 30% Secondary color para sa background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search deck',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Deck list section
              Expanded(
                child: Consumer<DeckProvider>(
                  builder: (context, deckProvider, child) {
                    if (deckProvider.isLoading && deckProvider.decks.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allDecks = deckProvider.decks;
                    final filteredDecks = _searchQuery.isEmpty
                        ? allDecks
                        : allDecks.where((d) =>
                            d.title.toLowerCase().contains(_searchQuery) ||
                            d.subject.toLowerCase().contains(_searchQuery)).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        if (allDecks.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total No. of\nDecks',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor, // 60% Dominant
                                  height: 1.1,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.style_outlined, color: primaryColor, size: 35),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${filteredDecks.length}', 
                                    style: const TextStyle(
                                      fontSize: 55,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor, // 10% Accent/Action
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                        ],

                        // List of Cards
                        if (filteredDecks.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No decks yet.\nCreate one to start studying!'
                                    : 'No decks found for "$_searchQuery"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryColor.withValues(alpha: 0.5), 
                                  fontSize: 16
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredDecks.length,
                              itemBuilder: (context, index) {
                                final deck = filteredDecks[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.read<DeckProvider>().selectDeck(deck);
                                    Navigator.pushNamed(context, 'mode');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Card Icon with Secondary Background
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: secondaryColor, // 30% background ng icon
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.auto_awesome_motion, color: primaryColor),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                deck.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${deck.totalCards} ${deck.totalCards < 2 ? 'Flashcard' : 'Flashcards'}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: accentColor), // 10% Accent
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}