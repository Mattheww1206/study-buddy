import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  bool isEditMode = false;
  
  // Controllers para sa Subject at Title (Biology, Cell Division, etc.)
  final TextEditingController _subjectController = TextEditingController(text: "Biology");
  final TextEditingController _titleController = TextEditingController(text: "Cell Division");

  // List of card data
  List<Map<String, TextEditingController>> cardControllers = [
    {
      "term": TextEditingController(text: ""),
      "def": TextEditingController(text: ""),
    }
  ];

  List<int> selectedIndices = [];

  @override
  void dispose() {
    // Linisin ang lahat ng controllers para iwas memory leak
    _subjectController.dispose();
    _titleController.dispose();
    for (var card in cardControllers) {
      card["term"]?.dispose();
      card["def"]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE), // INIBA: Dominant Color
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/studybuddy-logo.png',
          height: 95,
          fit: BoxFit.contain,
          
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Create Deck", 
                            style: GoogleFonts.lora(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
                          Text("${cardControllers.length} cards total", 
                            style: GoogleFonts.lora(color: const Color(0xFF665FBE), fontSize: 16)), 
                        ],
                      ),
                      // Edit/Close Button
                      Container(
                        decoration: BoxDecoration(
                          color: isEditMode ? const Color(0xFF421C21) : const Color(0xFFFAEEFF), 
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isEditMode = !isEditMode;
                              selectedIndices.clear();
                            });
                          },
                          icon: Icon(isEditMode ? Icons.close : Icons.edit, size: 20, color: isEditMode ? Colors.white : const Color(0xFF665FBE)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- DELETE BAR ---
                  if (isEditMode && selectedIndices.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF2D1616), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Selected ${selectedIndices.length}", 
                              style: GoogleFonts.lora(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B1111)),
                            onPressed: () {
                              setState(() {
                                selectedIndices.sort((a, b) => b.compareTo(a));
                                for (var index in selectedIndices) {
                                  cardControllers[index]["term"]?.dispose();
                                  cardControllers[index]["def"]?.dispose();
                                  cardControllers.removeAt(index);
                                }
                                selectedIndices.clear();
                                isEditMode = false;
                              });
                            },
                            child: Text("Delete", style: GoogleFonts.lora(color: Colors.white)),
                          )
                        ],
                      ),
                    ),

                  // --- SUBJECT & TITLE SECTION ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF665FBE).withOpacity(0.1))), 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SUBJECT", style: GoogleFonts.lora(color: const Color(0xFF665FBE).withOpacity(0.5), fontSize: 15, fontWeight: FontWeight.bold)), 
                              TextFormField(
                                controller: _subjectController,
                                decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                                style: GoogleFonts.lora(fontWeight: FontWeight.w600, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFAEEFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF665FBE).withOpacity(0.1))), 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TITLE", style: GoogleFonts.lora(color: const Color(0xFF665FBE).withOpacity(0.5), fontSize: 15, fontWeight: FontWeight.bold)), 
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                                style: GoogleFonts.lora(color: const Color(0xFFFF7B67), fontWeight: FontWeight.w600, fontSize: 20), 
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- FLASHCARDS LIST ---
                  ...cardControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    var controllers = entry.value;
                    bool isSelected = selectedIndices.contains(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF0F0) : const Color(0xFFFAEEFF), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.red.shade200 : const Color(0xFF665FBE).withOpacity(0.2)), 
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isEditMode)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      isSelected ? selectedIndices.remove(index) : selectedIndices.add(index);
                                    });
                                  },
                                  icon: Container(
                                    width: 22, height: 22,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF665FBE) : Colors.white, 
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF665FBE), width: 2), 
                                    ),
                                    child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? const Color(0xFFFF7B67) : const Color(0xFF665FBE), 
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${index + 1}", 
                                  style: GoogleFonts.lora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Text("Card", 
                                style: GoogleFonts.lora(color: const Color(0xFF665FBE), fontWeight: FontWeight.bold, fontSize: 20)), 
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text("TERM", style: GoogleFonts.lora(color: const Color(0xFF665FBE).withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF665FBE).withOpacity(0.1))),
                            child: TextFormField(
                              controller: controllers["term"],
                              style: GoogleFonts.lora(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: "Enter term...", 
                                border: InputBorder.none, 
                                hintStyle: GoogleFonts.lora(fontSize: 18, color: Colors.grey)
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text("DEFINITION", style: GoogleFonts.lora(color: const Color(0xFF665FBE).withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF665FBE).withOpacity(0.1))),
                            child: TextFormField(
                              controller: controllers["def"],
                              maxLines: null,
                              style: GoogleFonts.lora(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: "Enter definition...", 
                                border: InputBorder.none, 
                                hintStyle: GoogleFonts.lora(fontSize: 18, color: Colors.grey)
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTONS BAR ---
          if (!isEditMode)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          
                     
                          List<Map<String, String>> finalCards = cardControllers.map((c) => {
                            "term": c["term"]!.text,
                            "def": c["def"]!.text,
                          }).toList();

                  
                          Map<String, dynamic> deckData = {
                            "subject": _subjectController.text,
                            "title": _titleController.text,
                            "cardCount": finalCards.length,
                            "cards": finalCards,
                          };

                         
                          Navigator.pop(context, deckData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7B67), 
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text("Save Deck", 
                          style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cardControllers.add({
                          "term": TextEditingController(),
                          "def": TextEditingController(),
                        });
                      });
                    },
                    child: Container(
                      height: 55,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF665FBE), 
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.add, size: 30, color: Colors.white),
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