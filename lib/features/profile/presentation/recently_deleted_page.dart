import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/recentlyDeleted/model/recently_deleted_model.dart';
import 'package:studybuddy/features/recentlyDeleted/service/recently_deleted_service.dart';
import 'package:studybuddy/services/local_storage_service.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  final RecentlyDeletedService _service = RecentlyDeletedService();
  final LocalStorageService _localStorage = LocalStorageService();

  // Blue Palette Colors mula sa image mo
  final Color primaryBlue = const Color(0xFF1976D2);   // Dark Blue
  final Color backgroundBlue = const Color(0xFFE3F2FD); // Lightest Blue
  final Color accentBlue = const Color(0xFF2196F3);    // Bright Blue
  final Color darkBlueAccent = const Color(0xFF0D47A1); // Deep Blue

  bool _isEditing = false;
  final Set<String> _selectedIds = {}; 
  List<RecentlyDeletedItem> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
    _service.purgeExpiredItems(userId);
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    final items = await _localStorage.loadPendingDeletions();
    if (mounted) {
      setState(() => _pendingItems = items);
    }
  }

  void _toggleSelection(String deletedId) {
    setState(() {
      if (_selectedIds.contains(deletedId)) {
        _selectedIds.remove(deletedId);
      } else {
        _selectedIds.add(deletedId);
      }
    });
  }

  void _showValidationDialog({
    required String title,
    required String message,
    required Color actionColor,
    required IconData icon,
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

  List<RecentlyDeletedItem> _mergeItems(List<RecentlyDeletedItem> firestoreItems) {
    final Map<String, RecentlyDeletedItem> merged = {};
    for (final item in firestoreItems) {
      merged[item.deletedId] = item;
    }
    for (final item in _pendingItems) {
      merged[item.deletedId] = item;
    }
    final list = merged.values.toList();
    list.sort((a, b) {
      if (a.isPendingSync && !b.isPendingSync) return -1;
      if (!a.isPendingSync && b.isPendingSync) return 1;
      return b.deletedAt.compareTo(a.deletedAt);
    });
    return list;
  }

  Future<void> _restoreSelected(List<RecentlyDeletedItem> allItems) async {
    final selected = allItems.where((i) => _selectedIds.contains(i.deletedId)).toList();
    final hasPending = selected.any((i) => i.isPendingSync);
    if (hasPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Some items are waiting to sync. Connect to the internet first, then try restoring.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      for (final item in selected) {
        if (item.type == DeletedItemType.deck) {
          await _service.restoreDeck(item);
        } else {
          await _service.restoreFlashcard(item);
        }
      }
      setState(() {
        _selectedIds.clear();
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selected.length} item${selected.length > 1 ? 's' : ''} restored successfully.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _permanentlyDeleteSelected(List<RecentlyDeletedItem> allItems) async {
    final selected = allItems.where((i) => _selectedIds.contains(i.deletedId)).toList();
    try {
      await _service.permanentlyDeleteAll(selected);
      await _loadPendingItems();
      setState(() {
        _selectedIds.clear();
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selected.length} item${selected.length > 1 ? 's' : ''} permanently deleted.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showManageSheet(List<RecentlyDeletedItem> allItems) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 30),
              _buildSheetAction(
                icon: Icons.settings_backup_restore_rounded,
                title: "Restore Selected",
                subtitle: "Return items to your main library",
                color: primaryBlue,
                onTap: () {
                  Navigator.pop(context);
                  _showValidationDialog(
                    title: "Restore Items",
                    message: "Are you sure you want to bring back these items to your library?",
                    actionColor: primaryBlue,
                    icon: Icons.restore_page_rounded,
                    onConfirm: () => _restoreSelected(allItems),
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
                    onConfirm: () => _permanentlyDeleteSelected(allItems),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  Widget _buildItemCard(RecentlyDeletedItem item) {
    final isSelected = _selectedIds.contains(item.deletedId);
    final isDeck = item.type == DeletedItemType.deck;
    final daysLeft = item.daysLeft;
    final isPending = item.isPendingSync;

    Color expiryColor;
    if (isPending) {
      expiryColor = accentBlue;
    } else if (daysLeft <= 3) {
      expiryColor = Colors.red;
    } else if (daysLeft <= 7) {
      expiryColor = Colors.orange;
    } else {
      expiryColor = primaryBlue;
    }

    return GestureDetector(
      onTap: _isEditing ? () => _toggleSelection(item.deletedId) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? backgroundBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
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
                color: isSelected ? primaryBlue : Colors.grey.shade400,
              ),
              const SizedBox(width: 15),
            ],
            Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                color: backgroundBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDeck ? Icons.menu_book_rounded : Icons.style_rounded,
                color: accentBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.displayTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: backgroundBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDeck ? 'DECK' : 'CARD',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PENDING',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: accentBlue, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(item.displaySubtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    isPending ? 'Waiting to sync — restore requires internet' : (daysLeft == 0 ? 'Expires today' : '$daysLeft day${daysLeft == 1 ? '' : 's'} left'),
                    style: TextStyle(color: expiryColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Recently Deleted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<RecentlyDeletedItem>>(
        stream: _service.getUserDeletedItems(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _pendingItems.isEmpty) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
             final items = _mergeItems([]);
             return _buildBody(items);
          }
          final firestoreItems = snapshot.data ?? [];
          final items = _mergeItems(firestoreItems);
          return _buildBody(items);
        },
      ),
    );
  }

  Widget _buildBody(List<RecentlyDeletedItem> items) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: accentBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Decks and flashcards are kept for 30 days before being permanently removed.",
                      style: TextStyle(color: Color(0xFF1565C0), fontSize: 14, height: 1.3),
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
                    _isEditing ? "${_selectedIds.length} SELECTED" : "${items.length} ITEM${items.length == 1 ? '' : 'S'} • EXPIRES SOON",
                    style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                          if (!_isEditing) _selectedIds.clear();
                        });
                      },
                      child: Text(_isEditing ? "CANCEL" : "EDIT", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No recently deleted items', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _buildItemCard(items[index]),
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 24, left: 0, right: 0,
          child: Center(
            child: AnimatedScale(
              scale: (_isEditing && _selectedIds.isNotEmpty) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.extended(
                backgroundColor: darkBlueAccent,
                onPressed: () => _showManageSheet(items),
                label: Text("Manage (${_selectedIds.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}