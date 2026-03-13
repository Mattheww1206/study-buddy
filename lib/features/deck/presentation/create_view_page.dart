import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/flashcards/service/flashcard_service.dart';

class CreateViewPage extends StatefulWidget {
  const CreateViewPage({super.key});

  @override
  State<CreateViewPage> createState() => _CreateViewPageState();
}

class _CreateViewPageState extends State<CreateViewPage> {
  final DeckService _deckService = DeckService();
  final FlashcardService _flashcardService = FlashcardService();
  late Deck _deck;
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int editingIndex = -1;
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _defController = TextEditingController();

  final List<Map<String, TextEditingController>> _newCards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deck = ModalRoute.of(context)!.settings.arguments as Deck;
      _loadFlashcards();
    });
  }

  @override
  void dispose() {
    _termController.dispose();
    _defController.dispose();
    for (final card in _newCards) {
      card['term']?.dispose();
      card['def']?.dispose();
    }
    super.dispose();
  }
  
  Future<void> _loadFlashcards() async {
    try {
      final cards = await _deckService
          .getDeckFlashcards(_deck.deckId)
          .timeout(const Duration(seconds: 10));
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
        const SnackBar(content: Text('Failed to load Flashcards.')),
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
    // Confirmation Dialog for deleting flashcard
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
              const Text('Delete this card?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF665FBE))),
              const SizedBox(height: 10),
              const Text('Are you sure you want to delete this card? This action cannot be undone.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
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
      try {
        await _flashcardService.deleteFlashcard(
          deckId: _deck.deckId,
          cardId: cardId,
        );
        setState(() {
          _flashcards.removeWhere((c) => c.cardId == cardId);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete card.')),
        );
      }
    }
  }
  // Save flashcard edit
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
          const SnackBar(content: Text('Failed to update card.')));
    }
  }

  Future<void> _saveChanges() async {
    for (int i = 0; i < _newCards.length; i++) {
      if (_newCards[i]['def']!.text.trim().isEmpty ||
          _newCards[i]['term']!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('New card ${i + 1} is missing a term or definition.')));
        return;
      }
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
       _deckService.updateDeck(
        _deck.deckId,
        {
          'title': _deck.title,
          'subject': _deck.subject,
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
        const SnackBar(content: Text('Deck updated Successfully.')),
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
      backgroundColor: const Color(0xFFF3F2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
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
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
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
                            border: Border.all(color: const Color(0xFFFAEEFF), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SUBJECT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_deck.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            border: Border.all(color: const Color(0xFFFAEEFF), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TITLE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_deck.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFED9E4F))),
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
                                        width: 24, height: 24,
                                        decoration: const BoxDecoration(color: Color(0xFFED9E4F), shape: BoxShape.circle),
                                        child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF665FBE))),
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
                                              _termController.text = card.question;
                                              _defController.text = card.answer;
                                            });
                                          }
                                        },
                                        child: Text(isCurrentlyEditing ? 'Done' : 'Edit', style: const TextStyle(color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                                      ),
                                      const Text(' | ', style: TextStyle(color: Colors.grey)),
                                      GestureDetector(
                                        onTap: () => _deleteFlashcard(card.cardId),
                                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text('TERM', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCurrentlyEditing ? Colors.white : const Color(0xFFFAEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isCurrentlyEditing ? const Color(0xFF665FBE) : Colors.transparent, width: 1.5),
                                ),
                                child: isCurrentlyEditing
                                    ? TextField(controller: _termController, decoration: const InputDecoration(border: InputBorder.none, isDense: true))
                                    : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(card.question)),
                              ),
                              const Text('DEFINITION', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCurrentlyEditing ? Colors.white : const Color(0xFFFAEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isCurrentlyEditing ? const Color(0xFF665FBE) : Colors.transparent, width: 1.5),
                                ),
                                child: isCurrentlyEditing
                                    ? TextField(controller: _defController, maxLines: null, decoration: const InputDecoration(border: InputBorder.none, isDense: true))
                                    : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(card.answer)),
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
                            border: Border.all(color: const Color(0xFF665FBE), width: 1.5),
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
                                        width: 24, height: 24,
                                        decoration: const BoxDecoration(color: Color(0xFF665FBE), shape: BoxShape.circle),
                                        child: Center(child: Text('${_flashcards.length + index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('New Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF665FBE))),
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
                                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text('TERM', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF665FBE), width: 1.5),
                                ),
                                child: TextField(controller: _newCards[index]['term'], decoration: const InputDecoration(hintText: 'Enter term...', border: InputBorder.none, isDense: true)),
                              ),
                              const Text('DEFINITION', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF665FBE), width: 1.5),
                                ),
                                child: TextField(controller: _newCards[index]['def'], maxLines: null, decoration: const InputDecoration(hintText: 'Enter definition...', border: InputBorder.none, isDense: true)),
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
                              color: _isSaving ? Colors.grey : const Color(0xFFED9E4F),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Save Deck', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: _addNewCard,
                        child: Container(
                          height: 60, width: 60,
                          decoration: BoxDecoration(color: const Color(0xFF665FBE), borderRadius: BorderRadius.circular(15)),
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