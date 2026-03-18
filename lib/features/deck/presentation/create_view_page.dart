import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/flashcards/service/flashcard_service.dart';

class CreateViewPage extends StatefulWidget {
  const CreateViewPage({super.key});

  @override
  State<CreateViewPage> createState() => _CreateViewPageState();
}

class _CreateViewPageState extends State<CreateViewPage> {


  final FlashcardService _flashcardService = FlashcardService();
  late Deck _deck;
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // New Theme Colors
  final Color dominantColor = const Color(0xFF1976D2);   // Solid Primary Blue
  final Color secondaryColor = const Color(0xFFF5F9FF);  // Very Light Blue/White Background
  final Color accentColor = const Color(0xFF2196F3);     // Accent Blue
  final Color actionBlue = const Color(0xFF1976D2);      // Action Blue

  bool _isEditingDeckInfo = false;
  int editingIndex = -1;
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _defController = TextEditingController();
  late TextEditingController _titleEditController = TextEditingController();
  late TextEditingController _subjectEditController = TextEditingController();

  final List<Map<String, TextEditingController>> _newCards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
      _titleEditController = TextEditingController(text: _deck.title);
      _subjectEditController = TextEditingController(text: _deck.subject);
      _loadFlashcards();
    });
  }

  @override
  void dispose() {
    _termController.dispose();
    _defController.dispose();
    _titleEditController.dispose();
    _subjectEditController.dispose();
    for (final card in _newCards) {
      card['term']?.dispose();
      card['def']?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    try {
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      await deckProvider.loadFlashcards(_deck.deckId);
      final cards = deckProvider.currentFlashcards;
      if (mounted) {
        setState(() {
          _flashcards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load Flashcards.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: dominantColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _addNewCard() {
    setState(() {
      _newCards.add({
        'term': TextEditingController(),
        'def': TextEditingController(),
      });
    });
  }

  Future<void> _deleteFlashcard(String cardId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isOnline = Provider.of<ConnectivityProvider>(context, listen: false).isOnline;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Move card to trash?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dominantColor)),
              const SizedBox(height: 10),
              Text(
                  isOnline
                      ? 'This card will be moved to Recently Deleted. You can restore it within 30 days.'
                      : 'You\'re offline. This card will be saved locally and synced to Recently Deleted when you reconnect.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('DELETE', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
      final isOnline = Provider.of<ConnectivityProvider>(context, listen: false).isOnline;
       final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      try {
        deckProvider.removeFlashcard(cardId);
        setState(() {
          _flashcards.removeWhere((c) => c.cardId == cardId);
        });

        await _flashcardService.deleteFlashcard(
          deckId: _deck.deckId,
          cardId: cardId,
          userId: userId,
          isOnline: isOnline,
          parentDeckTitle: _deck.title,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isOnline
                  ? 'Card moved to Recently Deleted.'
                  : 'Saved offline. Will sync when you reconnect.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: dominantColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete card.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: dominantColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _saveCardEdit(int index) async {
    try {
      await _flashcardService.updateFlashcard(
        deckId: _deck.deckId,
        cardId: _flashcards[index].cardId,
        question: _defController.text.trim(),
        answer: _termController.text.trim(),
      );
      setState(() {
        _flashcards[index] = Flashcard(
          cardId: _flashcards[index].cardId,
          deckId: _deck.deckId,
          question: _defController.text.trim(),
          answer: _termController.text.trim(),
        );
        editingIndex = -1;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update card.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: dominantColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
     final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    for (int i = 0; i < _newCards.length; i++) {
      if (_newCards[i]['def']!.text.trim().isEmpty ||
          _newCards[i]['term']!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New card ${i + 1} is missing a term or definition.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: dominantColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      await deckProvider.updateDeck(
        _deck.deckId,
        {
          'title': _titleEditController.text.trim(),
          'subject': _subjectEditController.text.trim(),
        },
      );

      for (final card in _newCards) {
        await _flashcardService.addFlashcard(
          deckId: _deck.deckId,
          question: card['def']!.text.trim(),
          answer: card['term']!.text.trim(),
        );
      }

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Deck updated Successfully.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: dominantColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Failed to save changes. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/studybuddy-logo.png',
          height: 95,
          fit: BoxFit.contain,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: dominantColor))
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isEditingDeckInfo = !_isEditingDeckInfo),
                        child: Text(
                          _isEditingDeckInfo ? 'Done' : 'Edit',
                          style: TextStyle(
                            color: dominantColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: _isEditingDeckInfo ? accentColor : Colors.white,
                                width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SUBJECT',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _subjectEditController,
                                readOnly: !_isEditingDeckInfo,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: _isEditingDeckInfo ? accentColor : Colors.white,
                                width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TITLE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _titleEditController,
                                readOnly: !_isEditingDeckInfo,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._flashcards.asMap().entries.map((entry) {
                        int index = entry.key;
                        Flashcard card = entry.value;
                        bool isCurrentlyEditing = editingIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
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
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                            color: accentColor, shape: BoxShape.circle),
                                        child: Center(
                                            child: Text('${index + 1}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Card',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: dominantColor)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (isCurrentlyEditing) {
                                            await _saveCardEdit(index);
                                          } else {
                                            setState(() {
                                              editingIndex = index;
                                              _termController.text = card.answer;
                                              _defController.text = card.question;
                                            });
                                          }
                                        },
                                        child: Text(isCurrentlyEditing ? 'Done' : 'Edit',
                                            style: TextStyle(
                                                color: actionBlue, fontWeight: FontWeight.bold)),
                                      ),
                                      const Text(' | ', style: TextStyle(color: Colors.grey)),
                                      GestureDetector(
                                        onTap: () => _deleteFlashcard(card.cardId),
                                        child: const Text('Delete',
                                            style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text('TERM',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: dominantColor,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCurrentlyEditing ? Colors.white : secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isCurrentlyEditing ? accentColor : Colors.transparent,
                                      width: 1.5),
                                ),
                                child: isCurrentlyEditing
                                    ? TextField(
                                        controller: _termController,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none, isDense: true))
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(card.answer)),
                              ),
                              Text('DEFINITION',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: dominantColor,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCurrentlyEditing ? Colors.white : secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isCurrentlyEditing ? accentColor : Colors.transparent,
                                      width: 1.5),
                                ),
                                child: isCurrentlyEditing
                                    ? TextField(
                                        controller: _defController,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none, isDense: true))
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(card.question)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      ..._newCards.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor, width: 1.5),
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
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                            color: actionBlue, shape: BoxShape.circle),
                                        child: Center(
                                            child: Text('${_flashcards.length + index + 1}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold))),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('New Card',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: dominantColor)),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _newCards[index]['term']?.dispose();
                                        _newCards[index]['def']?.dispose();
                                        _newCards.removeAt(index);
                                      });
                                    },
                                    child: const Text('Remove',
                                        style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text('TERM',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: dominantColor,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: accentColor, width: 1.5),
                                ),
                                child: TextField(
                                    controller: _newCards[index]['term'],
                                    decoration: const InputDecoration(
                                        hintText: 'Enter term...',
                                        border: InputBorder.none,
                                        isDense: true)),
                              ),
                              Text('DEFINITION',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: dominantColor,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: accentColor, width: 1.5),
                                ),
                                child: TextField(
                                    controller: _newCards[index]['def'],
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter definition...',
                                        border: InputBorder.none,
                                        isDense: true)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSaving ? null : _saveChanges,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isSaving ? Colors.grey : actionBlue,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: actionBlue.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Save Deck',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: _addNewCard,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: accentColor, borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.add, color: Colors.white, size: 30),
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