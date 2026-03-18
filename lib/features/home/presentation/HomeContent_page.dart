import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContentPage> {
  final DeckService _deckService = DeckService();
  late Stream<List<Deck>> _decksStream;
  bool _isLoading = false;
  
  // Mock data for your results (Replace with your actual logic)
  final List<dynamic> _results = []; 

  @override
  void initState() {
    super.initState();
    // Using the stream with includeMetadataChanges: true for instant offline updates
    _decksStream = _deckService.getDecksStream();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Deck>>(
              stream: _decksStream,
              builder: (context, snapshot) {
                // 1. Handle initial loading
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final decks = snapshot.data ?? [];

                // 2. GLOBAL EMPTY STATE
                // This is the fix: If 0 decks, everything disappears and shows this.
                if (decks.isEmpty) {
                  return _buildGlobalEmptyState();
                }

                // 3. DATA LOGIC (Filtered from the same source)
                final pinnedDecks = decks.where((d) => d.isPinned).toList();
                final recentDecks = decks.take(5).toList();
                final newlyAdded = decks.take(5).toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SafeArea(child: SizedBox(height: 10)),

                      // Pinned Section
                      if (pinnedDecks.isNotEmpty) ...[
                        _buildPinnedSection(pinnedDecks),
                        const SizedBox(height: 25),
                      ],

                      // Stats Section
                      _buildStatsSection(decks),
                      const SizedBox(height: 25),

                      // Recent Decks Section
                      const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Text('Recent Decks',
                            style: TextStyle(
                                color: Color(0xFF665FBE),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      _buildHorizontalList(recentDecks, isRecent: true),

                      const SizedBox(height: 35),

                      // Newly Added Section
                      const Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Text('Newly added decks',
                            style: TextStyle(
                                color: Color(0xFF665FBE),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      _buildHorizontalList(newlyAdded, isRecent: false),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- UI COMPONENTS (Keeping your exact styling) ---

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, 
               size: 80, 
               color: const Color(0xFF665FBE).withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text(
            'No decks yet.\nCreate one to start studying!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF665FBE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedSection(List<Deck> pinnedDecks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.push_pin, color: Color(0xFFFF7A01), size: 24),
              SizedBox(width: 10),
              Text('Pinned decks',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                return _buildDeckCard(deck, isPinnedCard: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<Deck> decks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(35)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('${decks.length}', 'DECKS CREATED'),
          Container(height: 40, width: 2, color: Colors.grey[100]),
          _buildStatColumn('${_results.where((r) => r.mode != 'flashcard').length}', 'QUIZ TAKEN'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF665FBE))),
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildHorizontalList(List<Deck> list, {required bool isRecent}) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildDeckCard(list[index], isPinnedCard: false, isRecentCard: isRecent);
        },
      ),
    );
  }

  Widget _buildDeckCard(Deck deck, {bool isPinnedCard = false, bool isRecentCard = true}) {
    return GestureDetector(
      onTap: () {
        Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
        Navigator.pushNamed(context, 'mode');
      },
      child: Container(
        width: isPinnedCard ? 250 : 200,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Recent/Pinned use Purple, Newly Added uses White with Border
          color: (isPinnedCard || isRecentCard) ? const Color(0xFF665FBE) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: (!isPinnedCard && !isRecentCard) 
              ? Border.all(color: const Color(0xFF665FBE).withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPinnedCard)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.push_pin, color: Color(0xFFFF7A01), size: 20),
              ),
            Text(
              deck.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: (isPinnedCard || isRecentCard) ? Colors.white : const Color(0xFF665FBE),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${deck.totalCards} Cards',
              style: TextStyle(
                  color: (isPinnedCard || isRecentCard) ? Colors.white70 : Colors.black54,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}