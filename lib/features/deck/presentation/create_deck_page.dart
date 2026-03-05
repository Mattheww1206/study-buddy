import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  bool isEditMode = false;
  
  List<Map<String, TextEditingController>> cardControllers = [
    {
      "term": TextEditingController(text: ""),
      "def": TextEditingController(text: ""),
    }
  ];

  List<int> selectedIndices = [];

  @override
  void dispose() {
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
        backgroundColor: const Color(0xFF0D0068),
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
                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Create Deck", 
                            style: GoogleFonts.lora(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
                          Text("${cardControllers.length} cards total", 
                            style: GoogleFonts.lora(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isEditMode ? const Color(0xFF421C21) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  isEditMode = !isEditMode;
                                  selectedIndices.clear();
                                });
                              },
                              icon: Icon(isEditMode ? Icons.close : Icons.edit, size: 20, color: isEditMode ? Colors.white : Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFFFF7B67), borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  cardControllers.add({
                                    "term": TextEditingController(),
                                    "def": TextEditingController(),
                                  });
                                });
                              },
                              icon: const Icon(Icons.add, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                 
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

            
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("SUBJECT", style: GoogleFonts.lora(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold)),
                              TextFormField(
                                initialValue: "Biology",
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
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TITLE", style: GoogleFonts.lora(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold)),
                              TextFormField(
                                initialValue: "Cell Division",
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

              
                  ...cardControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    var controllers = entry.value;
                    bool isSelected = selectedIndices.contains(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF0F0) : const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.red.shade200 : Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isEditMode)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isSelected ? selectedIndices.remove(index) : selectedIndices.add(index);
                                    });
                                  },
                                  icon: Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF4A4E69) : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF4A4E69), width: 2),
                                    ),
                                    child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? const Color(0xFFFF6B6B) : const Color(0xFF8E8FFA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${index + 1}", 
                                  style: GoogleFonts.lora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Text("Card", 
                                style: GoogleFonts.lora(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text("TERM", style: GoogleFonts.lora(color: Colors.black45, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
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
                          Text("DEFINITION", style: GoogleFonts.lora(color: Colors.black45, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
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

          if (!isEditMode)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deck saved!", style: GoogleFonts.lora())),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B67),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Save Deck", 
                    style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}