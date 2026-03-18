import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final ResultService _resultService = ResultService();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isLoading = false;

  // Blue 60-30-10 Palette
  final Color primaryColor = const Color(0xFF1976D2);   // 60%
  final Color secondaryColor = const Color(0xFFE3F2FD); // 30%
  final Color accentColor = const Color(0xFF2196F3);    // 10%

  // List of card data
  List<Map<String, TextEditingController>> cardControllers = [
    {
      "term": TextEditingController(text: ""),
      "def": TextEditingController(text: ""),
    }
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    for (var card in cardControllers) {
      card["term"]?.dispose();
      card["def"]?.dispose();
    }
    super.dispose();
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B67).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Color(0xFFFF7B67),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Delete this card?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, 
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to delete this card?\nThis action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            cardControllers[index]["term"]?.dispose();
                            cardControllers[index]["def"]?.dispose();
                            cardControllers.removeAt(index);
                          });
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7B67),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveDeck() async {
    if (_titleController.text.trim().isEmpty || _subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Title and Subject are required."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    for (int i = 0; i < cardControllers.length; i++) {
      if (cardControllers[i]['term']!.text.trim().isEmpty ||
          cardControllers[i]['def']!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Card ${i + 1} is missing a term or definition."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      final cards = cardControllers.map((card) => {
            'term': card['term']!.text.trim(),
            'def': card['def']!.text.trim(),
          }).toList();
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
          deckProvider.createDeck(
          userId: userProvider.user!.userId,
          title: _titleController.text.trim(),
          subject: _subjectController.text.trim(),
          cards: cards
      ).catchError((e) => print('Error saving decks: $e'));

      messenger.showSnackBar(
          SnackBar(
            content: Text('Deck Saved!',),
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
      );
      nav.pop();

     final decks = deckProvider.decks;
      final results = await _resultService.getUserResults(userProvider.user!.userId);
      final streak = _resultService.calculateStreak(results);

      AchievementService().evaluateAndUnlock(
        userId: userProvider.user!.userId,
        results: results,
        decks: decks,
        streak: streak,
      ).catchError((e) => print('Achievement eval error: $e'));

    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to save deck.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Deck",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15), // Itinaas ang top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deck Info Row (Total cards count displayed here)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Deck Info",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A))),
                      Text("${cardControllers.length} cards",
                          style: TextStyle(
                              color: primaryColor, 
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Subject and Title Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: primaryColor
                                      .withValues(alpha: 0.05))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SUBJECT",
                                  style: TextStyle(
                                      color: primaryColor
                                          .withValues(alpha: 0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              TextFormField(
                                controller: _subjectController,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: primaryColor
                                      .withValues(alpha: 0.05))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TITLE",
                                  style: TextStyle(
                                      color: primaryColor
                                          .withValues(alpha: 0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero),
                                style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Cards List
                  ...cardControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    var controllers = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? accentColor
                                          : primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("${index + 1}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text("Card",
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              if (cardControllers.length > 1)
                                IconButton(
                                  onPressed: () => _confirmDelete(index),
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Color(0xFFFF7B67), size: 24),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text("TERM",
                              style: TextStyle(
                                  color: primaryColor
                                      .withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: primaryColor
                                        .withValues(alpha: 0.05))),
                            child: TextFormField(
                              controller: controllers["term"],
                              style: const TextStyle(fontSize: 15),
                              decoration: const InputDecoration(
                                  hintText: "Enter term...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text("DEFINITION",
                              style: TextStyle(
                                  color: primaryColor
                                      .withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: primaryColor
                                        .withValues(alpha: 0.05))),
                            child: TextFormField(
                              controller: controllers["def"],
                              maxLines: null,
                              style: const TextStyle(fontSize: 15),
                              decoration: const InputDecoration(
                                  hintText: "Enter definition...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveDeck,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text('Save Deck',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      cardControllers.add({
                        "term": TextEditingController(),
                        "def": TextEditingController(),
                      });
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 55,
                    decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}