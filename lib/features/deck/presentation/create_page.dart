import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'create_deck_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Colors
  final Color colorDominant = const Color(0xFF665FBE); // Purple
  final Color colorSecondary = const Color(0xFFFAEEFF); // Solid background color
  final Color colorAccent = const Color(0xFFFF7A00); // Orange
  final DeckService _deckService = DeckService();

  // Data & State
  final List<Map<String, dynamic>> decks = [];
  bool isDeleteMode = false;
  Set<String> selectedDecksIds = {}; 
  bool _isDeleting = false;

  void _deleteSelectedDecks() async {
    if (selectedDecksIds.isEmpty) return;

    setState(() => _isDeleting = true);

    try {
      for (final deckId in selectedDecksIds) {
        await _deckService.deleteDeck(deckId);
      }
      setState(() {
        selectedDecksIds.clear();
        isDeleteMode = false;
      });
    } catch (e) {
      if(!mounted) return ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete deck. Please try again.'))
      );
    } finally {
      if(mounted) setState(() => _isDeleting = false);
    }
  }

   void _toggleDeckSelection(String deckId) {
    setState(() {
      if (selectedDecksIds.contains(deckId)) {
        selectedDecksIds.remove(deckId);
      } else {
        selectedDecksIds.add(deckId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).user?.userId ?? '';

     return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: colorSecondary,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: StreamBuilder<List<Deck>>(
                    stream: _deckService.getUserDecks(userId),
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 300),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 300),
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        );
                      }

                      final decks = snapshot.data ?? [];

                      return Column(
                        children: [
                          // search bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: colorDominant.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: 'Search deck',
                                hintStyle: TextStyle(
                                  color: colorDominant.withOpacity(0.5),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Icon(Icons.search,
                                      color: colorDominant, size: 30),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total No. of\nDecks',
                                    style: TextStyle(
                                      color: colorDominant,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      if (isDeleteMode) {
                                        if (selectedDecksIds.isNotEmpty) {
                                          _deleteSelectedDecks();
                                        } else {
                                          setState(() {
                                            isDeleteMode = false;
                                            selectedDecksIds.clear();
                                          });
                                        }
                                      } else {
                                        if (decks.isNotEmpty) {
                                          setState(() => isDeleteMode = true);
                                        }
                                      }
                                    },
                                    child: _isDeleting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Text(
                                            isDeleteMode
                                                ? (selectedDecksIds.isEmpty
                                                    ? 'Cancel'
                                                    : 'Confirm Delete (${selectedDecksIds.length})')
                                                : 'Delete',
                                            style: TextStyle(
                                              color: isDeleteMode
                                                  ? (selectedDecksIds.isEmpty
                                                      ? Colors.grey
                                                      : Colors.red)
                                                  : const Color(0xFF9FB2C8),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.style_outlined,
                                      size: 40, color: colorDominant),
                                  Text(
                                    ' ${decks.length}',
                                    style: TextStyle(
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      color: colorDominant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Divider(
                            color: colorDominant.withOpacity(0.2),
                            thickness: 2,
                            height: 25,
                          ),

                          // deck list
                          if (decks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 250),
                              child: Text(
                                'No Decks Created yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: colorDominant.withOpacity(0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            // 👇 iterates over Deck objects from Firestore
                            ...decks.map((deck) {
                              bool isSelected =
                                  selectedDecksIds.contains(deck.deckId);

                              return GestureDetector(
                                onTap: isDeleteMode
                                    ? () => _toggleDeckSelection(deck.deckId)
                                    : () => Navigator.pushNamed(
                                          context,
                                          'create_view',
                                          arguments: deck, // 👈 pass Deck object
                                        ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: isDeleteMode && isSelected
                                        ? Border.all(color: Colors.red, width: 2)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      if (isDeleteMode)
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: Colors.red,
                                          onChanged: (value) =>
                                              _toggleDeckSelection(deck.deckId),
                                        ),
                                      Icon(Icons.style,
                                          color: colorAccent, size: 45),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deck.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: colorDominant,
                                              ),
                                            ),
                                            Text(
                                              '${deck.subject} | ${deck.totalCards} Cards',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isDeleteMode) ...[
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: colorDominant.withOpacity(0.1),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero),
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            'create_view',
                                            arguments: deck, 
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility,
                                                  color: colorAccent, size: 20),
                                              Text(' VIEW DECK',
                                                  style: TextStyle(
                                                    color: colorAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isDeleteMode
            ? null
            : GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'create_deck'),
                child: Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorAccent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: colorAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 45),
                ),
              ),
      );
    }
  }