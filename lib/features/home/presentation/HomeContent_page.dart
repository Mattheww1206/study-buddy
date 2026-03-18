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
  final bool _isLoading = false;

  // Blue 60-30-10 Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%

  final PageController _pinnedController = PageController(viewportFraction: 0.65);
  final PageController _recentController = PageController(viewportFraction: 0.65);
  final PageController _newlyAddedController = PageController(viewportFraction: 0.65);

  final List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _decksStream = _deckService.getDecksStream();
  }

  @override
  void dispose() {
    _pinnedController.dispose();
    _recentController.dispose();
    _newlyAddedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: secondaryColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : StreamBuilder<List<Deck>>(
              stream: _decksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                final decks = snapshot.data ?? [];
                if (decks.isEmpty) return _buildGlobalEmptyState();

                final pinnedDecks = decks.where((d) => d.isPinned).toList();
                final recentDecks = decks.take(5).toList();
                final newlyAdded = decks.take(5).toList();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SafeArea(child: SizedBox(height: 10)),
                      
                      // NAGDAGDAG NG OVERVIEW HEADER DITO
                      _buildSectionHeader('Overview'),
                      const SizedBox(height: 15),
                      _buildStatsSection(decks),
                      const SizedBox(height: 25),

                      if (pinnedDecks.isNotEmpty) ...[
                        _buildPinnedSection(pinnedDecks),
                        const SizedBox(height: 25),
                      ],

                      _buildSectionHeader('Recent Decks'),
                      const SizedBox(height: 15),
                      _buildSwipeableSection(recentDecks, _recentController, isRecent: true),
                      const SizedBox(height: 35),
                      _buildSectionHeader('Newly added decks'),
                      const SizedBox(height: 15),
                      _buildSwipeableSection(newlyAdded, _newlyAddedController, isRecent: false),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Text(title,
          style: const TextStyle(
              color: primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5)),
    );
  }

  Widget _buildPageIndicator(int count, PageController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        int currentPage = 0;
        if (controller.hasClients && controller.page != null) {
          currentPage = controller.page!.round();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            bool isActive = (currentPage.clamp(0, count - 1)) == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 18 : 6,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSwipeableSection(List<Deck> decks, PageController controller, {required bool isRecent}) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 25),
            child: PageView.builder(
              controller: controller,
              padEnds: false,
              itemCount: decks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: _buildDeckCard(decks[index], isRecentCard: isRecent),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: _buildPageIndicator(decks.length, controller),
        ),
      ],
    );
  }

  Widget _buildPinnedSection(List<Deck> pinnedDecks) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.only(top: 20, bottom: 30),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Icon(Icons.push_pin, color: accentColor, size: 24),
                    SizedBox(width: 10),
                    Text('Pinned decks',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: PageView.builder(
                    controller: _pinnedController,
                    padEnds: false,
                    itemCount: pinnedDecks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildDeckCard(pinnedDecks[index], isPinnedCard: true),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 15,
          child: _buildPageIndicator(pinnedDecks.length, _pinnedController),
        ),
      ],
    );
  }

  Widget _buildStatsSection(List<Deck> decks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('${decks.length}', 'DECKS'),
          Container(height: 40, width: 1.5, color: secondaryColor),
          _buildStatColumn('${_results.where((r) => r.mode != 'flashcard').length}', 'QUIZZES'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildDeckCard(Deck deck, {bool isPinnedCard = false, bool isRecentCard = true}) {
    bool isColored = isPinnedCard || isRecentCard;

    return GestureDetector(
      onTap: () {
        Provider.of<DeckProvider>(context, listen: false).selectDeck(deck);
        Navigator.pushNamed(context, 'mode');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isColored ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: !isColored
              ? Border.all(color: primaryColor.withOpacity(0.2), width: 1.5)
              : null,
          boxShadow: [
            if (isColored)
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.layers_rounded,
              size: 36,
              color: isColored ? Colors.white : primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              deck.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isColored ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              '${deck.totalCards} Cards',
              style: TextStyle(
                  color: isColored ? Colors.white70 : Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined,
              size: 80,
              color: primaryColor.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text('No decks yet.\nStart your journey today!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}