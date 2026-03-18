import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/model/achievement_model.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  // Blue Palette definition based on 60-30-10
  final Color primaryBlue = const Color(0xFF1976D2);   // 60%
  final Color backgroundBlue = const Color(0xFFE3F2FD); // 30%
  final Color accentBlue = const Color(0xFF2196F3);    // 10%

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;
    if (userId == null) return;
    final achievements = await _achievementService.getAchievements(userId);
    if (mounted) {
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    final locked = _achievements.where((a) => !a.isUnlocked).length;

    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Achievements',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Stats
                  Row(
                    children: [
                      _buildStatBox('$unlocked', 'UNLOCKED', accentBlue),
                      const SizedBox(width: 15),
                      _buildStatBox('$locked', 'LOCKED', primaryBlue),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text('ALL ACHIEVEMENTS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[600])),
                    ],
                  ),

                  const SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _achievements.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final item = _achievements[index];
                      final icon = _getIcon(item.icon);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: item.isUnlocked
                              ? Border.all(color: accentBlue, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 5)
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Lock Icon - Nasa top-right pa rin
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(
                                item.isUnlocked ? Icons.lock_open : Icons.lock,
                                color: item.isUnlocked
                                    ? accentBlue
                                    : Colors.grey[300],
                                size: 14,
                              ),
                            ),
                            
                            // Itong Center widget ang magpapatalsik sa lahat sa gitna
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Mahalaga para mag-center vertically
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center, // Horizontal centering
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: item.isUnlocked
                                            ? backgroundBlue
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: item.isUnlocked
                                            ? primaryBlue
                                            : Colors.grey[300],
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item.isUnlocked
                                              ? Colors.black87
                                              : Colors.grey[500]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.desc,
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[400],
                                          height: 1.1),
                                    ),
                                    if (item.isUnlocked && item.unlockedAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.unlockedAt!.month}/${item.unlockedAt!.day}/${item.unlockedAt!.year}',
                                        style: TextStyle(
                                            fontSize: 7,
                                            color: primaryBlue.withOpacity(0.7)),
                                      ),
                                    ],
                                  ],
                                ),
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
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}