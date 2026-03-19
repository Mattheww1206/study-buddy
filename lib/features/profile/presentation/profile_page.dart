import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/model/achievement_model.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/results/provider/result_provider.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ResultService _resultService = ResultService();
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String? _userId;
  bool _initialized = false;

  // Blue Palette Colors
  final Color primaryBlue = const Color(0xFF1976D2);   // Darker Blue
  final Color backgroundBlue = const Color(0xFFE3F2FD); // Lightest Blue
  final Color accentBlue = const Color(0xFF2196F3);    // Bright Blue
  final Color streakBlue = const Color(0xFF1976D2);    // Pinalit sa orange

  IconData _getIcon(String iconName) {
    const map = {
      'handshake': Icons.handshake,
      'note_add': Icons.note_add,
      'menu_book': Icons.menu_book,
      'collections_bookmark': Icons.collections_bookmark,
      'favorite': Icons.favorite,
      'quiz': Icons.quiz,
      'psychology': Icons.psychology,
      'face': Icons.face,
      'calendar_month': Icons.calendar_month,
      'emoji_events': Icons.emoji_events,
      'star_border': Icons.star_border,
      'military_tech': Icons.military_tech,
      'workspace_premium': Icons.workspace_premium,
      'auto_awesome': Icons.auto_awesome,
      'explore_outlined': Icons.explore_outlined,
      'shuffle': Icons.shuffle,
      'search': Icons.search,
      'checklist': Icons.checklist,
      'rule': Icons.rule,
      'rate_review': Icons.rate_review,
      'bolt': Icons.bolt,
      'diamond': Icons.diamond,
    };
    return map[iconName] ?? Icons.emoji_events;
  }

  Future<void> _loadResultsThenAchievements() async {
  final resultProvider = Provider.of<ResultProvider>(context, listen: false);
  await resultProvider.loadResults(_userId!);
  await _loadAchievements();
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    _initialized = true;
    _userId = user.userId;
    _loadResultsThenAchievements();
  }

  Future<void> _loadAchievements() async {
  try {
    final resultService = ResultService();
    final results = await resultService.getUserResults(_userId!);
    final deckService = DeckService();
    final decks = await deckService.getUserDecks(_userId!).first;
    final streak = resultService.calculateStreak(results);

    await _achievementService.evaluateAndUnlock(
      userId: _userId!,
      results: results,
      decks: decks,
      streak: streak,
    );

    final achievements = await _achievementService.getAchievements(_userId!);
    if (!mounted) return;
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  } catch (e, stack) {
    print('_loadAchievements error: $e');
    print('stack: $stack');
    if (mounted) setState(() => _isLoading = false);
  }
}

  Widget get _defaultAvatar => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [const Color(0xFF90CAF9), backgroundBlue],
          ),
        ),
        child: const Icon(Icons.person, size: 90, color: Colors.black54),
      );

  Widget _buildPerformanceItem(String subject, String title, String date, String score, String status, Color scoreColor, Color statusColor) {
    return Card(
      elevation: 6, 
      color: Colors.white, 
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0), 
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: backgroundBlue, borderRadius: BorderRadius.circular(15)),
              child: Icon(Icons.assessment_rounded, color: primaryBlue)),
          const SizedBox(width: 15),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryBlue)),
            const SizedBox(height: 2),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(score, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 18, color: scoreColor)),
            Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ]),
        ]),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    final loggedUser = Provider.of<UserProvider>(context).user;
    final photoUrl = loggedUser?.photoUrl;
    final resultProvider = context.watch<ResultProvider>();

    final streak = resultProvider.streak; 
    final unlockedList = _achievements.where((a) => a.isUnlocked).toList();
    final unlockedCount = unlockedList.length;
    final totalAchievements = _achievements.length;
    final overallProgress = totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;
    final overallPercent = (overallProgress * 100).toInt();

    return Scaffold(
      backgroundColor: backgroundBlue, 
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<DeckProvider>(
              builder: (context, deckProvider, child) {
                final decks = deckProvider.decks;
                final totalDecks = decks.length;
                final totalQuizTaken = resultProvider.totalQuizTaken;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset('assets/studybuddy-logo.png', height: 70, fit: BoxFit.contain),
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                      child: IconButton(
                                        icon: const Icon(Icons.settings, color: Colors.white, size: 25),
                                        onPressed: () => Navigator.pushNamed(context, 'settings'),
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: backgroundBlue,
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: photoUrl != null
                                          ? Image.memory(base64Decode(photoUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar)
                                          : _defaultAvatar,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(loggedUser?.username ?? 'Student', style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 26)),
                                const SizedBox(height: 10),
                                
                                // UPDATED: Streak color is now backgroundBlue to match the page background
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: backgroundBlue, 
                                    borderRadius: BorderRadius.circular(30), 
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_fire_department, color: primaryBlue, size: 20),
                                      const SizedBox(width: 6),
                                      Text('$streak Day Study Streak', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Main Stats Card
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: [Text('$totalDecks', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: primaryBlue)), Text('Decks\nCreated', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBlue))]),
                                Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
                                Column(children: [Text('$totalQuizTaken', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: primaryBlue)), Text('Quiz\nTaken', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBlue))]),
                                Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
                                Column(children: [Text('$streak', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: primaryBlue)), Text('Day\nStreak', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: primaryBlue))]),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Recent Performance Section
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recent Performance', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: primaryBlue)),
                            const SizedBox(height: 20),
                            resultProvider.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : resultProvider.results.isEmpty
                                    ? const Center(child: Text('No recent activity yet.'))
                                    : SizedBox(
                                        // Eto yung sikreto: Fixed height para sa 3 items lang
                                        height: 330, 
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          // Pinalitan natin ito para maging scrollable ang loob ng card
                                          physics: const AlwaysScrollableScrollPhysics(), 
                                          itemCount: resultProvider.results.take(10).length,
                                          itemBuilder: (context, index) {
                                           final result = resultProvider.results.take(10).toList()[index]; 
                                            final passed = result.correctCount >= (result.totalCards / 2);
                                            final date = '${_monthName(result.completedAt.month)} ${result.completedAt.day}, ${result.completedAt.year}';
                                            
                                            return _buildPerformanceItem(
                                              result.deckSubject,
                                              result.deckTitle,
                                              date,
                                              '${result.correctCount}/${result.totalCards}',
                                              passed ? 'PASSED' : 'FAILED',
                                              accentBlue, 
                                              passed ? Colors.green : Colors.red,
                                            );
                                          },
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),

                      // Achievements Section
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Achievements', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 22, color: primaryBlue)),
                                    TextButton(onPressed: () => Navigator.pushNamed(context, 'achievement'), child: Text('See All', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: unlockedList.length,
                                  itemBuilder: (context, index) {
                                    final achieve = unlockedList[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      child: Container(
                                        width: 120,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Icon(_getIcon(achieve.icon), size: 40, color: accentBlue),
                                          const SizedBox(height: 8),
                                          Text(achieve.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lora(fontSize: 13, fontWeight: FontWeight.bold))
                                        ]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$unlockedCount of $totalAchievements unlocked', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue.withValues(alpha: 0.7))), Text('$overallPercent%', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: accentBlue))]),
                                    const SizedBox(height: 8),
                                    ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: overallProgress, backgroundColor: backgroundBlue, color: accentBlue, minHeight: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }
}