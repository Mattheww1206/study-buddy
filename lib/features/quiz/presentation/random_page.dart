import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: RandomPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  // Global App Colors
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF6D00);

  // State Variables
  int currentIndex = 0; 
  final TextEditingController _answerController = TextEditingController();
  String? selectedOption;

  // --- SAMPLE DATA STRUCTURE ---
  // Dito natin ilalagay ang mga tanong. Pwedeng halo ang type.
  final List<Map<String, dynamic>> quizData = [
    {
      "type": "multiple",
      "question": "What type of cell division produces 4 genetically unique daughter cells?",
      "options": ["Mitosis", "Meiosis", "Binary Fission", "Cytokinesis"],
    },
    {
      "type": "identification",
      "question": "What is the powerhouse of the cell?",
    },
    {
      "type": "multiple",
      "question": "Which organelle is responsible for photosynthesis?",
      "options": ["Nucleus", "Chloroplast", "Ribosome", "Vacuole"],
    },
    {
      "type": "identification",
      "question": "What is the basic unit of life?",
    },
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current question data
    var currentData = quizData[currentIndex];
    bool isMultipleChoice = currentData["type"] == "multiple";
    bool isLastQuestion = currentIndex == quizData.length - 1;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            if (currentIndex > 0) {
              setState(() => currentIndex--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text("Biology Quiz", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView( 
          child: Column(
            children: [
              _buildStatusSection(),
              const SizedBox(height: 10),
              _buildQuestionCard(currentData["question"]),
              const SizedBox(height: 25),
              
              // Dynamic Body base sa type ng tanong
              if (isMultipleChoice) 
                _buildMultipleChoiceOptions(currentData["options"]) 
              else 
                _buildIdentificationInput(),
                
              const SizedBox(height: 20),
              _buildActionButton(isLastQuestion),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI BUILDER METHODS ---

  Widget _buildStatusSection() {
    double progress = (currentIndex + 1) / quizData.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question ${currentIndex + 1}/${quizData.length}", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: dominantColor, fontSize: 22)),
                  Text("${(progress * 100).toInt()}% Completed", 
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16)),
                ],
              ),
              _buildTimerPill(),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              color: accentColor,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: dominantColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: dominantColor, size: 18),
          const SizedBox(width: 6),
          const Text("18:42", style: TextStyle(color: Color(0xFF665FBE), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(color: dominantColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(List<dynamic> currentOptions) {
    return Column(
      children: currentOptions.map((option) {
        bool isSelected = selectedOption == option;
        String letter = String.fromCharCode(65 + currentOptions.indexOf(option));
        return GestureDetector(
          onTap: () => setState(() => selectedOption = option.toString()),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? dominantColor : Colors.transparent, width: 2.5),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isSelected ? dominantColor : secondaryColor,
                  child: Text(letter, style: TextStyle(color: isSelected ? Colors.white : dominantColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                Text(option.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIdentificationInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Answer:", style: TextStyle(color: dominantColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: dominantColor.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: dominantColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isLastQuestion) {
    return Padding(
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
          onPressed: () {
            if (!isLastQuestion) {
              setState(() {
                currentIndex++;
                // Reset fields para sa next question
                selectedOption = null;
                _answerController.clear();
              });
            } else {
              // Submit Logic
              Navigator.pushNamed(context, 'ran_result');
            }
          },
          child: Text(
            isLastQuestion ? "Submit Quiz" : "Next Question", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}