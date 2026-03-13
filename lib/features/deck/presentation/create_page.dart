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
  // Color Palette Application
  final Color colorDominant = const Color(0xFF665FBE);
  final Color colorSecondary = const Color(0xFFFAEEFF);
  final Color colorAccent = const Color(0xFFFF7A00);
  final Color colorWhite = Colors.white;

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
      backgroundColor: colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: colorDominant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Manage New Deck",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: colorDominant
                ),
              ),
              const SizedBox(height: 25),
              _buildModalOption(
                icon: Icons.add_card_rounded,
                title: 'Create Deck',
                subtitle: 'Manual entry of cards',
                iconBg: colorSecondary,
                iconColor: colorDominant,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'create_deck');
                },
              ),
              const SizedBox(height: 15),
              _buildModalOption(
                icon: Icons.upload_file_rounded,
                title: 'Upload Files',
                subtitle: 'Generate cards from PDF or images',
                iconBg: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'upload');
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  // --- MODAL PARA SA ACTION OPTIONS ---
  void _showActionOptions(List<Deck> allDecks) {
    final selectedDecks = allDecks.where((d) => selectedDecksIds.contains(d.deckId));
    bool isAllPinned = selectedDecks.every((d) => d.isPinned);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorSecondary,
                  child: Icon(isAllPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, color: colorDominant),
                ),
                title: Text(isAllPinned ? 'Unpin Selected' : 'Pin Selected', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () => _handlePinDecks(allDecks),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEFEF),
                  child: Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Delete Selected', 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteSelected();
                },
              ),
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
        backgroundColor: colorWhite,
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: StadiumBorder()),
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
      backgroundColor: colorSecondary,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: StreamBuilder<List<Deck>>(
                  stream: _decksStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: colorDominant));
                    }
                    final decks = snapshot.data ?? [];
                    final sortedDecks = List<Deck>.from(decks);
                    sortedDecks.sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));

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
                              elevation: 4,
                              child: const Icon(Icons.add, color: Colors.white, size: 35),
                            ),
                      body: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            // --- SEARCH BAR DESIGN ---
                            Container(
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorDominant.withOpacity(0.08), 
                                    blurRadius: 20, 
                                    offset: const Offset(0, 10)
                                  )
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                                decoration: InputDecoration(
                                  hintText: 'Search your study deck...',
                                  hintStyle: TextStyle(color: colorDominant.withOpacity(0.4)),
                                  prefixIcon: Icon(Icons.search_rounded, color: colorDominant),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            
                            // --- HEADER DESIGN ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Library', style: TextStyle(color: colorDominant.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text('My Decks', style: TextStyle(color: colorDominant, fontSize: 32, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        isEditMode = !isEditMode;
                                        selectedDecksIds.clear();
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isEditMode ? Colors.red.withOpacity(0.1) : colorDominant.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Text(isEditMode ? 'Cancel Edit' : 'Edit Library',
                                          style: TextStyle(color: isEditMode ? Colors.red : colorDominant, fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: colorDominant.withOpacity(0.1))
                                  ),
                                  child: Column(
                                    children: [
                                      Text('${filteredDecks.length}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorAccent)),
                                      Text('DECKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorDominant.withOpacity(0.5))),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 25),
                            
                            // --- DECK LIST DESIGN ---
                            ...filteredDecks.map((deck) {
                              bool isSelected = selectedDecksIds.contains(deck.deckId);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: isEditMode ? () => _toggleSelection(deck.deckId) : () => Navigator.pushNamed(context, 'create_view', arguments: deck),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected ? colorDominant : Colors.transparent, 
                                        width: 2
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected ? colorDominant.withOpacity(0.1) : Colors.black.withOpacity(0.03), 
                                          blurRadius: 15, 
                                          offset: const Offset(0, 8)
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        if (isEditMode)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Icon(
                                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                              color: colorDominant,
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorSecondary,
                                            borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Icon(Icons.collections_bookmark_rounded, color: colorDominant, size: 30),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(deck.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorDominant)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(color: colorAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                                                    child: Text(deck.subject, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorAccent)),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text('${deck.totalCards} Cards', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (deck.isPinned)
                                          Icon(Icons.push_pin_rounded, color: colorAccent, size: 20),
                                      ],
                                    ),
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
          if (_isProcessing)
            Container(color: Colors.black45, child: Center(child: CircularProgressIndicator(color: colorAccent))),
        ],
      ),
    );
  }
}