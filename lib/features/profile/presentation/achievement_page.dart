import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final List<Map<String, dynamic>> achievements = [
    {"title": "Unstoppable", "desc": "Get 10 correct answers in a row", "icon": Icons.bolt},
    {"title": "Comeback Kid", "desc": "Pass a quiz after previously failing it", "icon": Icons.book},
    {"title": "Clean Sweep", "desc": "Answer all questions correctly in one sitting", "icon": Icons.auto_awesome},
    {"title": "Rising Star", "desc": "Score 70%+ on your first quiz", "icon": Icons.star_border},
    {"title": "High Achiever", "desc": "Score 90%+ three times", "icon": Icons.military_tech},
    {"title": "Top of the Class", "desc": "Score 100% three times", "icon": Icons.workspace_premium},
    {"title": "Explorer", "desc": "Try all 3 quiz modes (MC, ID, Random)", "icon": Icons.explore_outlined},
    {"title": "Mix Master", "desc": "Complete a Random Mix quiz", "icon": Icons.shuffle},
    {"title": "Identifier", "desc": "Complete an Identification quiz", "icon": Icons.search},
    {"title": "Choice Maker", "desc": "Complete a Multiple Choice quiz", "icon": Icons.checklist},
    {"title": "Two Weeks Strong", "desc": "Study 14 days in a row", "icon": Icons.calendar_month},
    {"title": "Monthly Champion", "desc": "Study 30 days in a row", "icon": Icons.emoji_events},
    {"title": "Collector", "desc": "Have 10 decks saved", "icon": Icons.collections_bookmark},
    {"title": "Reviewer", "desc": "Review wrong answers after a quiz", "icon": Icons.rate_review},
    {"title": "First Comeback", "desc": "Retake a quiz you previously failed", "icon": Icons.history_edu},
    {"title": "Fox Friend", "desc": "Log in 3 days in a row", "icon": Icons.face},
    {"title": "Fox Favorite", "desc": "Complete 5 quizzes total", "icon": Icons.favorite},
    {"title": "Fox Legend", "desc": "Unlock 10 achievements", "icon": Icons.diamond},
    {"title": "Welcome!", "desc": "Create your account", "icon": Icons.handshake},
    {"title": "Quiz x10", "desc": "Complete 10 quizzes total", "icon": Icons.quiz},
    {"title": "Quiz x50", "desc": "Complete 50 quizzes total", "icon": Icons.psychology},
    {"title": "Bookworm", "desc": "Create 5 different decks", "icon": Icons.menu_book},
    {"title": "Card Maker", "desc": "Create your first flashcard deck", "icon": Icons.note_add},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        title: Text(
          'Achievements',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Stats
            Row(
              children: [
                _buildStatBox("0", "UNLOCKED", Colors.orange),
                const SizedBox(width: 15),
                _buildStatBox(achievements.length.toString(), "LOCKED", const Color(0xFF7165D6)),
              ],
            ),
            
            const SizedBox(height: 30),
            
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  "ALL ACHIEVEMENTS",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.65, 
              ),
              itemBuilder: (context, index) {
                final item = achievements[index];
                
                // fall back icons if ever maging null
                final IconData displayIcon = item['icon'] != null 
                    ? item['icon'] as IconData 
                    : Icons.emoji_events;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(Icons.lock, color: Colors.orange, size: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(displayIcon, color: Colors.grey[300], size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'] ?? 'No Title',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.grey[600]
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'] ?? 'No Description',
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 8, 
                                color: Colors.grey[400],
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Text(count, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}