import 'package:flutter/material.dart';
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

  // Data & State
  final List<Map<String, dynamic>> decks = [];
  bool isDeleteMode = false;
  Set<int> selectedDecks = {}; 

  Future<void> _navigateToCreateDeck() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDeckPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        decks.add(result);
      });
    }
  }

  void _deleteSelectedDecks() {
    setState(() {
      List<int> sortedIndices = selectedDecks.toList()..sort((a, b) => b.compareTo(a));
      for (var index in sortedIndices) {
        decks.removeAt(index);
      }
      selectedDecks.clear();
      isDeleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    // --- SEARCH BAR ---
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
                            child: Icon(Icons.search, color: colorDominant, size: 30),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- HEADER SECTION (UPDATED SIZES) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end, // Pantay sa ilalim
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total No. of\nDecks',
                              style: TextStyle(
                                color: colorDominant,
                                fontSize: 22, // Liniitan mula 26
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isDeleteMode) {
                                    if (selectedDecks.isNotEmpty) {
                                      _deleteSelectedDecks();
                                    } else {
                                      isDeleteMode = false;
                                    }
                                  } else {
                                    if (decks.isNotEmpty) isDeleteMode = true;
                                  }
                                });
                              },
                              child: Text(
                                isDeleteMode 
                                    ? (selectedDecks.isEmpty ? 'Cancel' : 'Confirm Delete (${selectedDecks.length})')
                                    : 'Delete',
                                style: TextStyle(
                                  color: isDeleteMode ? (selectedDecks.isEmpty ? Colors.grey : Colors.red) : const Color(0xFF9FB2C8),
                                  fontSize: 16, // Liniitan mula 18
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon size adjusted to 40
                            Icon(Icons.style_outlined, size: 40, color: colorDominant),
                            Text(
                              ' ${decks.length}', 
                              style: TextStyle(
                                fontSize: 55, // Liniitan mula 85
                                fontWeight: FontWeight.bold,
                                color: colorDominant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Divider height adjusted to 25 para mas mataas ang linya
                    Divider(color: colorDominant.withOpacity(0.2), thickness: 2, height: 25),

                    // --- DECKS LIST ---
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
                      ...decks.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> deckData = entry.value;
                        bool isSelected = selectedDecks.contains(index);

                        return GestureDetector(
                          onTap: isDeleteMode ? () {
                            setState(() {
                              if (isSelected) {
                                selectedDecks.remove(index);
                              } else {
                                selectedDecks.add(index);
                              }
                            });
                          } : null,
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
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedDecks.add(index);
                                        } else {
                                          selectedDecks.remove(index);
                                        }
                                      });
                                    },
                                  ),
                                Icon(Icons.style, color: colorAccent, size: 45),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(deckData['title'] ?? 'Untitled Deck', 
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: colorDominant)),
                                      Text('${deckData['subject']} | ${deckData['cardCount']} Cards',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                if (!isDeleteMode)
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: colorDominant.withOpacity(0.1),
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                if (!isDeleteMode)
                                  TextButton(
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'create_view');
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, color: colorAccent, size: 20),
                                        Text(' VIEW DECK',
                                            style: TextStyle(
                                                color: colorAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- FLOATING ACTION BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isDeleteMode 
        ? null 
        : GestureDetector(
            onTap: _navigateToCreateDeck,
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