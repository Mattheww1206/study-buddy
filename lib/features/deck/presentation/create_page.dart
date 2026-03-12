import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Colors based on your palette
  final Color colorDominant = const Color(0xFF665FBE);
  final Color colorSecondary = const Color(0xFFFAEEFF);
  final Color colorAccent = const Color(0xFFFF7A00);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final DeckService _deckService = DeckService();

  bool isEditMode = false;
  Set<String> selectedDecksIds = {};
  bool _isProcessing = false;
  late Stream<List<Deck>> _decksStream;
  bool _isStreamInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isStreamInitialized) {
      final userId = Provider.of<UserProvider>(context).user?.userId ?? '';
      _decksStream = _deckService.getUserDecks(userId);
      _isStreamInitialized = true;
    }
  }

  void _toggleSelection(String deckId) {
    setState(() {
      if (selectedDecksIds.contains(deckId)) {
        selectedDecksIds.remove(deckId);
      } else {
        selectedDecksIds.add(deckId);
      }
    });
  }

  // --- MODAL PARA SA ADD BUTTON ---
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Manage New Deck",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorSecondary,
                  child: Icon(Icons.add_card_rounded, color: colorDominant),
                ),
                title: const Text('Create Deck',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text('Manual entry of cards'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'create_deck');
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.upload_file_rounded, color: Colors.green),
                ),
                title: const Text('Upload Files',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text('Generate cards from PDF or images'),
                onTap: () {
                  Navigator.pop(context);
                   Navigator.pushNamed(context, 'upload'); 
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL PARA SA EDIT/DELETE/PIN ---
  void _showActionOptions(List<Deck> allDecks) {
    final selectedDecks = allDecks.where((d) => selectedDecksIds.contains(d.deckId));
    bool isAllPinned = selectedDecks.every((d) => d.isPinned);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF0FF),
                  child: Icon(
                    isAllPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                    color: colorDominant,
                  ),
                ),
                title: Text(isAllPinned ? 'Unpin Deck' : 'Pin Deck',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () => _handlePinDecks(allDecks),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEFEF),
                  child: Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Delete Deck',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteSelected();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _handlePinDecks(List<Deck> allDecks) async {
    Navigator.pop(context);
    setState(() => _isProcessing = true);
    try {
      final selectedDecks = allDecks.where((d) => selectedDecksIds.contains(d.deckId));
      bool isAllPinned = selectedDecks.every((d) => d.isPinned);
      bool newPinnedStatus = !isAllPinned;

      for (var id in selectedDecksIds) {
        await _deckService.updateDeck(id, {'isPinned': newPinnedStatus});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newPinnedStatus ? 'Decks pinned!' : 'Decks unpinned!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorDominant,
          ),
        );
      }
      setState(() {
        selectedDecksIds.clear();
        isEditMode = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update.')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _confirmDeleteSelected() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFFEFEF), shape: BoxShape.circle),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 50),
            ),
            const SizedBox(height: 20),
            Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.bold, color: colorDominant)),
          ],
        ),
        content: Text("Are you sure you want to delete ${selectedDecksIds.length} deck(s)?", textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("DELETE"),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isProcessing = true);
      try {
        for (var id in selectedDecksIds) {
          await _deckService.deleteDeck(id);
        }
        setState(() {
          selectedDecksIds.clear();
          isEditMode = false;
        });
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete.')));
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorSecondary,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: StreamBuilder<List<Deck>>(
                    stream: _decksStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final decks = snapshot.data ?? [];
                      final sortedDecks = List<Deck>.from(decks);
                      sortedDecks.sort((a, b) {
                        if (a.isPinned == b.isPinned) return 0;
                        return a.isPinned ? -1 : 1;
                      });

                      final filteredDecks = sortedDecks.where((deck) =>
                        deck.title.toLowerCase().contains(_searchQuery) ||
                        deck.subject.toLowerCase().contains(_searchQuery)).toList();

                      return Scaffold(
                        backgroundColor: Colors.transparent,
                        floatingActionButton: isEditMode
                            ? (selectedDecksIds.isNotEmpty
                                ? FloatingActionButton.extended(
                                    onPressed: () => _showActionOptions(sortedDecks),
                                    label: Text('Manage (${selectedDecksIds.length})'),
                                    icon: const Icon(Icons.edit_note_rounded),
                                    backgroundColor: colorDominant,
                                  )
                                : null)
                            : FloatingActionButton(
                                onPressed: _showAddOptions,
                                backgroundColor: colorAccent,
                                child: const Icon(Icons.add, color: Colors.white, size: 40),
                              ),
                        body: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            children: [
                              // --- SEARCH BAR ---
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [BoxShadow(color: colorDominant.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                                  decoration: InputDecoration(
                                    hintText: 'Search deck',
                                    hintStyle: TextStyle(color: colorDominant.withOpacity(0.5), fontSize: 18),
                                    suffixIcon: Icon(Icons.search, color: colorDominant),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // --- HEADER ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total No. of\nDecks', style: TextStyle(color: colorDominant, fontSize: 22, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          isEditMode = !isEditMode;
                                          selectedDecksIds.clear();
                                        }),
                                        child: Text(isEditMode ? 'Cancel' : 'Edit',
                                            style: TextStyle(color: isEditMode ? Colors.red : const Color(0xFF9FB2C8), fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.style_outlined, size: 40, color: colorDominant),
                                      Text(' ${filteredDecks.length}', style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: colorDominant)),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(color: colorDominant.withOpacity(0.2), thickness: 2, height: 25),
                              // --- DECK LIST ---
                              ...filteredDecks.map((deck) {
                                bool isSelected = selectedDecksIds.contains(deck.deckId);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: GestureDetector(
                                    onTap: isEditMode ? () => _toggleSelection(deck.deckId) : () => Navigator.pushNamed(context, 'create_view', arguments: deck),
                                    child: Stack(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(25),
                                            border: Border.all(color: isEditMode && isSelected ? colorDominant : Colors.transparent, width: 2),
                                            boxShadow: [BoxShadow(color: isSelected ? colorDominant.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                                          ),
                                          child: Row(
                                            children: [
                                              if (isEditMode)
                                                Checkbox(
                                                  value: isSelected,
                                                  shape: const CircleBorder(),
                                                  activeColor: colorDominant,
                                                  onChanged: (v) => _toggleSelection(deck.deckId),
                                                ),
                                              Icon(Icons.style, color: colorAccent, size: 45),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(deck.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorDominant)),
                                                    Text('${deck.subject} | ${deck.totalCards} Cards', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (deck.isPinned)
                                          Positioned(right: 12, top: 12, child: Icon(Icons.push_pin_rounded, color: colorAccent, size: 18)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}