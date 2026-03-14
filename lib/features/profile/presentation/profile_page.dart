import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
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

    final List<Map<String, dynamic>> achievements = [
      {'title': 'First Deck', 'icon': Icons.style, 'progress': 1.0},
      {'title': 'Quiz Master', 'icon': Icons.psychology, 'progress': 0.6},
      {'title': '7-Day Streak', 'icon': Icons.local_fire_department, 'progress': 0.3},
      {'title': 'Early Bird', 'icon': Icons.wb_sunny, 'progress': 1.0},
    ];

    final int totalAchievements = achievements.length;
    final int unlockedCount = achievements.where((a) => a['progress'] == 1.0).length;
    final double overallProgress = totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;
    final int overallPercent = (overallProgress * 100).toInt();
    final List<Map<String, dynamic>> unlockedList = achievements.where((a) => a['progress'] == 1.0).toList();

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAEEFF), Color(0xFFFAEEFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                            height: 400,
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
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Image.asset('assets/studybuddy-logo.png', height: 80, fit: BoxFit.contain),
                                            Container(
                                              margin: const EdgeInsets.only(top: 10),
                                              decoration: BoxDecoration(color: Colors.white.withAlpha(51), shape: BoxShape.circle),
                                              child: IconButton(
                                                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                                                onPressed: () => Navigator.pushNamed(context, 'settings'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 50),
                                          child: CircleAvatar(
                                            radius: 65,
                                            backgroundColor: const Color(0xFFFAEEFF),
                                            child: ClipOval(
                                              child: SizedBox(
                                                width: 120, height: 120,
                                                child: photoUrl != null
                                                    ? Image.memory(base64Decode(photoUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar)
                                                    : _defaultAvatar,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(loggedUser?.username ?? 'Student', style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28)),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(color: const Color(0xFFFD9519), borderRadius: BorderRadius.circular(30)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                                          const SizedBox(width: 8),
                                          Text('$streak Day Study Streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Main Stats
                          Transform.translate(
                            offset: const Offset(0, -60),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(children: [Text('$totalDecks', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Decks\nCreated', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                                  Container(height: 40, width: 1, color: Colors.grey.withAlpha(51)),
                                  Column(children: [Text('$totalQuizTaken', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Quiz\nTaken', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                                  Container(height: 40, width: 1, color: Colors.grey.withAlpha(51)),
                                  Column(children: [Text('$streak', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF665FBE))), Text('Day\nStreak', textAlign: TextAlign.center, style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF665FBE)))]),
                                ],
                              ),
                            ),
                          ),

                          // Progress Section
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 5))],
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

            // --- RECENT PERFORMANCE SECTION ---
                                    Transform.translate(
                                    offset: const Offset(0, -20),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 5))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Recent Performance', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF665FBE))),
                                          const SizedBox(height: 20),

                                          // ITEM 1: Example with Subject, Topic, Date, and Status
                                          Row(children: [
                                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.history_edu, color: Color(0xFF665FBE))),
                                            const SizedBox(width: 15),
                                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const Text("Social Studies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF665FBE))), // SUBJECT
                                              const Text("Philippine History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // TOPIC
                                              Text("Mar 12, 2026", style: TextStyle(color: Colors.grey[600], fontSize: 11)), // DATE
                                            ])),
                                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                              Text("10/10", style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFFD9519))),
                                              const Text("PASSED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)), // STATUS
                                            ]),
                                          ]),

                                          const Divider(height: 25),

                                          // ITEM 2: Example with Subject, Topic, Date, and Status
                                          Row(children: [
                                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.code, color: Color(0xFF665FBE))),
                                            const SizedBox(width: 15),
                                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const Text("Computer Science", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF665FBE))), // SUBJECT
                                              const Text("Java Programming", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // TOPIC
                                              Text("Mar 10, 2026", style: TextStyle(color: Colors.grey[600], fontSize: 11)), // DATE
                                            ])),
                                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                              Text("4/10", style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
                                              const Text("FAILED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)), // STATUS
                                            ]),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),

                          // Achievements Section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 5))],
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
                                        width: 120, margin: const EdgeInsets.symmetric(horizontal: 8), padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: const Color(0xFFFAEEFF).withAlpha(127), borderRadius: BorderRadius.circular(20)),
                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(a['icon'], size: 40, color: const Color(0xFFFD9519)), const SizedBox(height: 8), Text(a['title'], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lora(fontSize: 13, fontWeight: FontWeight.bold))]),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$unlockedCount of $totalAchievements unlocked', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF665FBE).withAlpha(178))), Text('$overallPercent%', style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFD9519)))]),
                                      const SizedBox(height: 8),
                                      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: overallProgress, backgroundColor: const Color(0xFFFAEEFF), color: const Color(0xFFFD9519), minHeight: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}