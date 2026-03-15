import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import para sa status bar control
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final ResultService _resultService = ResultService();
  final DeckService _deckService = DeckService();

  List<StudyResult> _results = [];
  bool _isLoading = true;
  String? _userId;
  bool _initialized = false;
  late Stream<List<Deck>> _decksStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    _initialized = true;
    _userId = user.userId;
    _decksStream = _deckService.getUserDecks(_userId!);
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final results = await _resultService.getUserResults(_userId!);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Ginagawang visible ang status bar icons sa light background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.dark, // Para sa Android (itim na icons)
      statusBarBrightness: Brightness.light,    // Para sa iOS (itim na icons)
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Deck>>(
              stream: _decksStream,
              builder: (context, snapshot) {
                final decks = snapshot.data ?? [];
                final pinnedDecks = decks.where((d) => d.isPinned).toList();
                final recentDecks = decks.take(5).toList();
                final newlyAdded = decks.take(5).toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Naglagay ng SafeArea space para hindi matakpan ng status bar ang content
                      const SafeArea(child: SizedBox(height: 10)),

                      // Pinned decks
                      if (pinnedDecks.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: Offset(0, 8))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.push_pin,
                                      color: Color(0xFFFF7A01), size: 24),
                                  SizedBox(width: 10),
                                  Text('Pinned decks',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: pinnedDecks.length,
                                  itemBuilder: (context, index) {
                                    final deck = pinnedDecks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
                                        Navigator.pushNamed(context, 'mode');
                                      },
                                      child: Container(
                                        width: 250,
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF665FBE),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(Icons.push_pin,
                                                  color: Color(0xFFFF7A01),
                                                  size: 20),
                                            ),
                                            Text(
                                              deck.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${deck.totalCards} Flashcards',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14),
                                            ),
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

                      const SizedBox(height: 25),

                      // Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 35),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('${decks.length}',
                                    style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF665FBE))),
                                const Text('DECKS CREATED',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Container(
                                height: 40,
                                width: 2,
                                color: Colors.grey[100]),
                            Column(
                              children: [
                                Text('${_results.where((r) => r.mode != 'flashcard').length}',
                                    style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF665FBE))),
                                const Text('QUIZ TAKEN',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Recent Decks
                      const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Text('Recent Decks',
                            style: TextStyle(
                                color: Color(0xFF665FBE),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      recentDecks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text('No decks yet.',
                                  style: TextStyle(color: Colors.grey[500])),
                            )
                          : SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: recentDecks.length,
                                itemBuilder: (context, index) {
                                  final deck = recentDecks[index];
                                  return GestureDetector(
                                   onTap: () {
                                      Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
                                      Navigator.pushNamed(context, 'mode');
                                    },
                                    child: Container(
                                      width: 200,
                                      margin: const EdgeInsets.only(right: 15),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF665FBE),
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(deck.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          const SizedBox(height: 8),
                                          Text('${deck.totalCards} Cards',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 35),

                      // Newly Added
                      const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Text('Newly added decks',
                            style: TextStyle(
                                color: Color(0xFF665FBE),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      newlyAdded.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text('No decks yet.',
                                  style: TextStyle(color: Colors.grey[500])),
                            )
                          : SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: newlyAdded.length,
                                itemBuilder: (context, index) {
                                  final deck = newlyAdded[index];
                                  return GestureDetector(
                                   onTap: () {
                                      Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
                                      Navigator.pushNamed(context, 'mode');
                                    },
                                    child: Container(
                                      width: 200,
                                      margin: const EdgeInsets.only(right: 15),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color: const Color(0xFF665FBE)
                                                  .withValues(alpha: 0.3),
                                              width: 1.5)),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(deck.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Color(0xFF665FBE),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          const SizedBox(height: 8),
                                          Text('${deck.totalCards} Cards',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
    );
  }
}