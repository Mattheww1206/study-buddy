import 'package:flutter/material.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  bool _isEditing = false;
  final Set<int> _selectedIndices = {};

  // Mock Data
  final List<Map<String, dynamic>> _deletedItems = [
    {"title": "Biology — Chapter 3", "subtitle": "20 cards • Multiple Choice", "days": "2 days left"},
    {"title": "History — World War II", "subtitle": "15 cards • Identification", "days": "9 days left"},
    {"title": "Math — Algebra Basics", "subtitle": "30 cards • Random Mix", "days": "21 days left"},
  ];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  // PINAGANDANG VALIDATION DIALOG
  void _showValidationDialog({
    required String title,
    required String message,
    required Color actionColor,
    required IconData icon, // New parameter for aesthetics
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: actionColor.withOpacity(0.1),
                child: Icon(icon, color: actionColor, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: const Text("PROCEED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(String actionType) {
    setState(() {
      List<int> sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var index in sortedIndices) {
        _deletedItems.removeAt(index);
      }
      _selectedIndices.clear();
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Successfully ${actionType.toLowerCase()}ed items."),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF665FBE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // PINAGANDANG BOTTOM SHEET
  void _showManageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              _buildSheetAction(
                icon: Icons.settings_backup_restore_rounded,
                title: "Restore Selected",
                subtitle: "Return items to your main library",
                color: const Color(0xFF665FBE),
                onTap: () {
                  Navigator.pop(context);
                  _showValidationDialog(
                    title: "Restore Items",
                    message: "Are you sure you want to bring back these items to your library?",
                    actionColor: const Color(0xFF665FBE),
                    icon: Icons.restore_page_rounded,
                    onConfirm: () => _handleAction("Restor"),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSheetAction(
                icon: Icons.delete_forever_rounded,
                title: "Delete Permanently",
                subtitle: "This action cannot be undone",
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showValidationDialog(
                    title: "Confirm Delete",
                    message: "These items will be gone forever. This is your last chance to change your mind!",
                    actionColor: Colors.red,
                    icon: Icons.warning_amber_rounded,
                    onConfirm: () => _handleAction("Delet"),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // HELPER WIDGET PARA SA ACTIONS
  Widget _buildSheetAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        title: const Text(
          'Recently Deleted',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: (_isEditing && _selectedIndices.isNotEmpty) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2D266F),
          onPressed: _showManageSheet,
          label: Text("Manage (${_selectedIndices.length})", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(25, 20, 25, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.brown.shade700, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Items are kept for 30 days before being permanently removed.",
                    style: TextStyle(color: Color(0xFF8D6E63), fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing 
                      ? "${_selectedIndices.length} SELECTED" 
                      : "${_deletedItems.length} ITEMS • EXPIRES SOON",
                  style: const TextStyle(color: Color(0xFF665FBE), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) _selectedIndices.clear();
                    });
                  },
                  child: Text(
                    _isEditing ? "CANCEL" : "EDIT",
                    style: const TextStyle(color: Color(0xFF665FBE), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _deletedItems.isEmpty 
              ? const Center(child: Text("No recently deleted items", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: _deletedItems.length,
                  itemBuilder: (context, index) {
                    final item = _deletedItems[index];
                    final isSelected = _selectedIndices.contains(index);

                    return GestureDetector(
                      onTap: _isEditing ? () => _toggleSelection(index) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF3E5F5) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF665FBE) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (_isEditing) ...[
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? const Color(0xFF665FBE) : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 15),
                            ],
                            Container(
                              height: 50, width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2196F3), size: 24),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                  const SizedBox(height: 2),
                                  Text(item['subtitle'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(item['days'], style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
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
    );
  }
}