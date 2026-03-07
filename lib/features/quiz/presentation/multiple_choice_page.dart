import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MultipleChoicePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MultipleChoicePage extends StatefulWidget {
  const MultipleChoicePage({super.key});

  @override
  State<MultipleChoicePage> createState() => _MultipleChoicePageState();
}

class _MultipleChoicePageState extends State<MultipleChoicePage> {
  String? selectedOption;

  // Color Palette
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF6D00);

  final List<String> options = [
    "Mitosis",
    "Meiosis",
    "Binary Fission",
    "Cytokinesis"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Biology Quiz", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- UPDATED STATUS SECTION (Itinaas pa lalo) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15), // Binago mula 25 to 10 para tumaas
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Question Number & Percent
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question 2/10", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: dominantColor, fontSize: 22)),
                          const Text("20% Completed", 
                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                      
                      // Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: dominantColor.withOpacity(0.2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, color: dominantColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "18:42",
                              style: TextStyle(
                                color: dominantColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15), // Space sa pagitan ng Text/Timer at Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.2,
                      backgroundColor: Colors.white,
                      color: accentColor,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // --- QUESTION CARD ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Text(
                "What type of cell division produces 4 genetically unique daughter cells?",
                textAlign: TextAlign.center,
                style: TextStyle(color: dominantColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // --- OPTIONS LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  String optionText = options[index];
                  bool isSelected = selectedOption == optionText;
                  String letter = String.fromCharCode(65 + index);

                  return GestureDetector(
                    onTap: () => setState(() => selectedOption = optionText),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? dominantColor : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected ? dominantColor : secondaryColor,
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : dominantColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              optionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- CONFIRM BUTTON ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, 'multiple_result');
                  },
                  child: const Text("Confirm Answer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}