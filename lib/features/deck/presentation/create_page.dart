import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';


class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // --- BLUE 60-30-10 PALETTE APPLIED ---
  final Color colorDominant = const Color(0xFF1976D2);   // 60% (Primary)
  final Color colorSecondary = const Color(0xFFE3F2FD); // 30% (Secondary)
  final Color colorAccent = const Color(0xFF2196F3);    // 10% (Accent)
  final Color colorWhite = Colors.white;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  bool isEditMode = false;
  bool isOnline = true;
  Set<String> selectedDecksIds = {};
  bool _isProcessing = false;

  void _toggleSelection(String deckId) {
    setState(() {
      if (selectedDecksIds.contains(deckId)) {
        selectedDecksIds.remove(deckId);
      } else {
        selectedDecksIds.add(deckId);
      }
    });
  }

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
                  color: colorDominant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Manage New Deck",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorDominant),
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
                subtitle: 'Generate cards from PDF, Docx, Doc',
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
                onTap: () => _handlePinDecks(),
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

  void _handlePinDecks() async {
    Navigator.pop(context);
    setState(() => _isProcessing = true);
    try {
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      final selectedDecks = deckProvider.decks.where((d) => selectedDecksIds.contains(d.deckId));
      bool isAllPinned = selectedDecks.every((d) => d.isPinned);
      bool newPinnedStatus = !isAllPinned;
     

      for (var id in selectedDecksIds) {
        await deckProvider.updateDeck(id, {'isPinned': newPinnedStatus});
      }
      setState(() {
        selectedDecksIds.clear();
        isEditMode = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Failed to update.'), behavior: SnackBarBehavior.floating, backgroundColor: colorDominant, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _confirmDeleteSelected() async {
    final isOnline = Provider.of<ConnectivityProvider>(context, listen: false).isOnline;
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEFEF), 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              "Confirm Delete", 
              style: TextStyle(fontWeight: FontWeight.bold, color: colorDominant, fontSize: 24)
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete ${selectedDecksIds.length} deck(s)?", 
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "CANCEL", 
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "DELETE", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isProcessing = true);
      final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);

      try {
        for (var id in selectedDecksIds) {
          deckProvider.deleteDeck(id, userId: userId, isOnline: isOnline);
        }
        setState(() {
          selectedDecksIds.clear();
          isEditMode = false;
        });
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Moved to Recently Deleted.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colorDominant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Failed to delete.'), behavior: SnackBarBehavior.floating, backgroundColor: colorDominant, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),));
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
      backgroundColor: colorSecondary, // 30% Secondary Background
      floatingActionButton: Consumer<DeckProvider>(
        builder: (context, deckProvider, snapshot) {
          if (isEditMode) {
            return selectedDecksIds.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () => _showActionOptions(deckProvider.decks),
                    label: Text('Manage (${selectedDecksIds.length})'),
                    icon: const Icon(Icons.edit_note_rounded),
                    backgroundColor: colorDominant, // 60% Primary
                  )
                : const SizedBox.shrink();
          } else {
            return FloatingActionButton(
              onPressed: _showAddOptions,
              backgroundColor: colorAccent, // 10% Accent
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 35),
            );
          }
        }
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
               child: Consumer<DeckProvider>(
                builder: (context, deckProvider, child) {
                  if (deckProvider.isLoading && deckProvider.decks.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: colorDominant));
                  }
                  final allDecks = deckProvider.decks;
                  final filteredDecks = _searchQuery.isEmpty
                      ? allDecks
                      : allDecks.where((d) {
                          final q = _searchQuery.toLowerCase();
                          return d.title.toLowerCase().contains(q) ||
                              d.subject.toLowerCase().contains(q);
                        }).toList();
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: colorDominant.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                              decoration: InputDecoration(
                                hintText: 'Search deck',
                                hintStyle: TextStyle(color: colorDominant.withValues(alpha: 0.4)),
                                prefixIcon: Icon(Icons.search_rounded, color: colorDominant),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          
                          // Header Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Library', 
                                      style: TextStyle(color: colorDominant.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.w600)
                                    ),
                                    Text(
                                      'My Decks', 
                                      style: TextStyle(color: colorDominant, fontSize: 32, fontWeight: FontWeight.bold, height: 1.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        isEditMode = !isEditMode;
                                        selectedDecksIds.clear();
                                      }),
                                      child: Text(
                                        isEditMode ? 'Cancel' : 'Edit Library',
                                        style: TextStyle(
                                          color: isEditMode ? Colors.red : colorDominant.withValues(alpha: 0.4), 
                                          fontSize: 18, 
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Icon(Icons.style_outlined, color: colorDominant.withValues(alpha: 0.8), size: 36),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${filteredDecks.length}', 
                                        style: TextStyle(fontSize: 55, fontWeight: FontWeight.w900, color: colorAccent, height: 0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 25),
                          if (filteredDecks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 220), 
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      allDecks.isEmpty
                                        ? 'No decks yet.\nCreate one to start studying!'
                                        : 'No decks found for "$_searchQuery"',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colorDominant.withValues(alpha: 0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          else
                          ...filteredDecks.map((deck) {
                            bool isSelected = selectedDecksIds.contains(deck.deckId);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: isEditMode ? () => _toggleSelection(deck.deckId) : () {
                                  Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
                                  Navigator.pushNamed(context, 'create_view');
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: isSelected ? colorDominant : Colors.transparent, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? colorDominant.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03), 
                                        blurRadius: 15, 
                                        offset: const Offset(0, 8)
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isEditMode)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10, top: 12),
                                          child: Icon(
                                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                            color: colorDominant,
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: colorSecondary, borderRadius: BorderRadius.circular(15)),
                                        child: Icon(Icons.collections_bookmark_rounded, color: colorDominant, size: 30),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              deck.title, 
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorDominant),
                                              softWrap: true,
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: colorAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                                                  child: Text(
                                                    deck.subject, 
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorAccent),
                                                  ),
                                                ),
                                                Text(
                                                  '${deck.totalCards} ${deck.totalCards < 2 ? 'Flashcard' : 'Flashcards'}', 
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (deck.isPinned) 
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Icon(Icons.push_pin_rounded, color: colorAccent, size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 100),
                        ],
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