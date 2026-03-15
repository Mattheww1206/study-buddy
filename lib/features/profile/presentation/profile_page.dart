import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/model/achievement_model.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DeckService _deckService = DeckService();
  final ResultService _resultService = ResultService();
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];

  List<StudyResult> _results = [];
  bool _isLoading = true;
  String? _userId;
  bool _initialized = false;
  late Stream<List<Deck>> _decksStream;

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
      final decks = await _deckService.getUserDecks(_userId!).first;
      final streak = _resultService.calculateStreak(results);

      await _achievementService.evaluateAndUnlock(
        userId: _userId!,
        results: results,
        decks: decks,
        streak: streak,
      );
      final achievements = await _achievementService.getAchievements(_userId!);
      if (!mounted) return;
      setState(() {
        _results = results;
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget get _defaultAvatar => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFF90CAF9), Color(0xFFE1F5FE)],
          ),
        ),
        child: const Icon(Icons.person, size: 90, color: Colors.black54),
      );

  Widget _buildPerformanceItem(String subject, String topic, String date, String score, String status, Color scoreColor, Color statusColor) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.assessment_rounded, color: Color(0xFF665FBE))),
      const SizedBox(width: 15),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF665FBE))),
        Text(topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(score, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 18, color: scoreColor)),
        Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
      ]),
    ]);
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

    final streak = _resultService.calculateStreak(_results);
    final todayCount = _resultService.todayQuizCount(_results);
    final weekCount = _resultService.weekQuizCount(_results);

    const dailyGoal = 6;
    const weeklyGoal = 15;
    final dailyProgress = (todayCount / dailyGoal).clamp(0.0, 1.0);
    final weeklyProgress = (weekCount / weeklyGoal).clamp(0.0, 1.0);
    final dailyPercent = (dailyProgress * 100).toInt();
    final weeklyPercent = (weeklyProgress * 100).toInt();

    final unlockedList = _achievements.where((a) => a.isUnlocked).toList();
    final unlockedCount = unlockedList.length;
    final totalAchievements = _achievements.length;
    final overallProgress = totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;
    final overallPercent = (overallProgress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Deck>>(
              stream: _decksStream,
              builder: (context, snapshot) {
                final decks = snapshot.data ?? [];
                final totalDecks = decks.length;
                final totalQuizTaken = _results.where((r) => r.mode != 'flashcard').length;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF665FBE),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            // BINABAWASAN ANG TOP PADDING PARA UMAKYAT ANG LOGO AT SETTINGS
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10), 
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LOGO
                                    Image.asset('assets/studybuddy-logo.png', height: 70, fit: BoxFit.contain),
                                    // SETTINGS ICON
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                      child: IconButton(
                                        icon: const Icon(Icons.settings, color: Colors.white, size: 25),
                                        onPressed: () => Navigator.pushNamed(context, 'settings'),
                                      ),
                                    ),
                                  ],
                                ),
                                // BINAWASAN ANG SPACING SA PAGITAN NG LOGO AT AVATAR
                                const SizedBox(height: 0), 
                                CircleAvatar(
                                  radius: 60, // Bahagyang nilian ang avatar para mas umakyat lahat
                                  backgroundColor: const Color(0xFFFAEEFF),
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
                                // STREAK BADGE
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFFD9519), borderRadius: BorderRadius.circular(30)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                                      const SizedBox(width: 6),
                                      Text('$streak Day Study Streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50), // Space para sa naka-float na card
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Main Stats Card
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(children: [Text('$totalDecks', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Decks\nCreated', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                              Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
                              Column(children: [Text('$totalQuizTaken', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Quiz\nTaken', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                              Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
                              Column(children: [Text('$streak', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Day\nStreak', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                            ],
                          ),
                        ),
                      ),

                      // Progress Section
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Daily Study ($todayCount / $dailyGoal)', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE))),
                              const SizedBox(height: 12),
                              Row(children: [const Icon(Icons.check, color: Color(0xFF665FBE), size: 24), const SizedBox(width: 8), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: dailyProgress, backgroundColor: const Color(0xFFFAEEFF), color: const Color(0xFF665FBE), minHeight: 15))), const SizedBox(width: 10), Text('$dailyPercent%', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE)))]),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.grey, thickness: 0.5)),
                              Text('Weekly Study ($weekCount / $weeklyGoal)', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE))),
                              const SizedBox(height: 12),
                              Row(children: [const Icon(Icons.check, color: Color(0xFF665FBE), size: 24), const SizedBox(width: 8), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: weeklyProgress, backgroundColor: const Color(0xFFFAEEFF), color: const Color(0xFF665FBE), minHeight: 15))), const SizedBox(width: 10), Text('$weeklyPercent%', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE)))]),
                            ],
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
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recent Performance', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE))),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 240,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  children: [
                                    _buildPerformanceItem("Social Studies", "Philippine History", "Mar 12, 2026", "10/10", "PASSED", const Color(0xFFFD9519), Colors.green),
                                    const Divider(height: 25),
                                    _buildPerformanceItem("Computer Science", "Java Programming", "Mar 10, 2026", "4/10", "FAILED", Colors.redAccent, Colors.red),
                                    const Divider(height: 25),
                                    _buildPerformanceItem("Science", "Environmental Science", "Mar 09, 2026", "9/10", "PASSED", const Color(0xFFFD9519), Colors.green),
                                    const Divider(height: 25),
                                    _buildPerformanceItem("History", "World War II", "Mar 08, 2026", "8/10", "PASSED", const Color(0xFFFD9519), Colors.green),
                                    const Divider(height: 25),
                                    _buildPerformanceItem("Programming", "Dart Basics", "Mar 07, 2026", "10/10", "PASSED", const Color(0xFFFD9519), Colors.green),
                                  ],
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
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Achievements', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF665FBE))),
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
                                    final a = unlockedList[index];
                                    return Container(
                                      width: 120,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFFAEEFF).withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_getIcon(a.icon), size: 40, color: const Color(0xFFFD9519)), const SizedBox(height: 8), Text(a.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lora(fontSize: 13, fontWeight: FontWeight.bold))]),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$unlockedCount of $totalAchievements unlocked', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF665FBE).withOpacity(0.7))), Text('$overallPercent%', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFD9519)))]),
                                    const SizedBox(height: 8),
                                    ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: overallProgress, backgroundColor: const Color(0xFFFAEEFF), color: const Color(0xFFFD9519), minHeight: 10)),
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