import 'package:flutter/material.dart';

class CreateViewPage extends StatefulWidget {
  const CreateViewPage({super.key});

  @override
  State<CreateViewPage> createState() => _CreateViewPageState();
}

class _CreateViewPageState extends State<CreateViewPage> {
  List<Map<String, String>> cardsData = [
    {'term': 'Meiosis', 'definition': 'Produces four genetically unique haploid cells'},
    {'term': 'Mitosis', 'definition': 'Cell division producing two identical daughter cells'},
  ];

  int editingIndex = -1;
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _defController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F8), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE), 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("StudyBuddy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFAEEFF), width: 2), 
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SUBJECT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Biology', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFAEEFF), width: 2),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TITLE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Cell Division', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFED9E4F))), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cardsData.length,
              itemBuilder: (context, index) {
                bool isCurrentlyEditing = editingIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(color: Color(0xFFED9E4F), shape: BoxShape.circle), 
                                child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 8),
                        
                              const Text('Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF665FBE))), 
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isCurrentlyEditing) {
                                      cardsData[index]['term'] = _termController.text;
                                      cardsData[index]['definition'] = _defController.text;
                                      editingIndex = -1;
                                    } else {
                                      editingIndex = index;
                                      _termController.text = cardsData[index]['term']!;
                                      _defController.text = cardsData[index]['definition']!;
                                    }
                                  });
                                },
                             
                                child: Text(isCurrentlyEditing ? 'Done' : 'Edit', style: const TextStyle(color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                              ),
                              const Text(' | ', style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    cardsData.removeAt(index);
                                    if (isCurrentlyEditing) editingIndex = -1;
                                  });
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // INAPPLY: Dominant #665FBE sa labels
                      const Text('TERM', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)), 
                      
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                
                          color: isCurrentlyEditing ? Colors.white : const Color(0xFFFAEEFF), 
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isCurrentlyEditing ? const Color(0xFF665FBE) : Colors.transparent, width: 1.5),
                        ),
                        child: isCurrentlyEditing 
                          ? TextField(
                              controller: _termController,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                            )
                          : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(cardsData[index]['term']!)),
                      ),

                      const Text('DEFINITION', style: TextStyle(fontSize: 10, color: Color(0xFF665FBE), fontWeight: FontWeight.bold)),
                      
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          // INAPPLY: Secondary #FAEEFF as background fill
                          color: isCurrentlyEditing ? Colors.white : const Color(0xFFFAEEFF), 
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isCurrentlyEditing ? const Color(0xFF665FBE) : Colors.transparent, width: 1.5),
                        ),
                        child: isCurrentlyEditing 
                          ? TextField(
                              controller: _defController,
                              maxLines: null,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                            )
                          : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(cardsData[index]['definition']!)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                
                    decoration: BoxDecoration(color: const Color(0xFFED9E4F), borderRadius: BorderRadius.circular(30)), 
                    child: const Center(
                      child: Text('Save Deck', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      cardsData.add({'term': 'New Term', 'definition': 'New Definition'});
                    });
                  },
                  child: Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(color: const Color(0xFF665FBE), borderRadius: BorderRadius.circular(15)), 
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}