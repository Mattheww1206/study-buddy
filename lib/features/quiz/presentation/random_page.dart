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
  bool isMultipleChoice = true; // Dito natin lalaruin kung anong design ang lalabas
  String? selectedOption;
  final TextEditingController _answerController = TextEditingController();

  final List<String> options = [
    "Mitosis",
    "Meiosis",
    "Binary Fission",
    "Cytokinesis"
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

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
            if (!isMultipleChoice) {
              setState(() => isMultipleChoice = true);
            }
          },
        ),
        title: const Text("Biology Quiz", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Para hindi mag-overflow pag lumabas ang keyboard
          child: Column(
            children: [
              // --- STATUS SECTION (Common sa dalawang design) ---
              _buildStatusSection(),

              const SizedBox(height: 10),

              // --- QUESTION CARD (Common sa dalawang design) ---
              _buildQuestionCard(isMultipleChoice 
                ? "What type of cell division produces 4 genetically unique daughter cells?" 
                : "What is the powerhouse of the cell?"),

              const SizedBox(height: 25),

              // --- DYNAMIC CONTENT (Dito magpapalit ang UI) ---
              if (isMultipleChoice) 
                _buildMultipleChoiceOptions() 
              else 
                _buildIdentificationInput(),

              const SizedBox(height: 20),

              // --- ACTION BUTTON ---
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI BUILDER METHODS ---

  Widget _buildStatusSection() {
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
                  Text(isMultipleChoice ? "Question 1/10" : "Question 2/10", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: dominantColor, fontSize: 22)),
                  Text(isMultipleChoice ? "10% Completed" : "20% Completed", 
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
              value: isMultipleChoice ? 0.1 : 0.2,
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
          Text("18:42", style: TextStyle(color: dominantColor, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // DESIGN: Multiple Choice
  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: options.map((option) {
        bool isSelected = selectedOption == option;
        String letter = String.fromCharCode(65 + options.indexOf(option));
        return GestureDetector(
          onTap: () => setState(() => selectedOption = option),
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
                Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // DESIGN: Identification
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

  Widget _buildActionButton() {
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
          ),
          onPressed: () {
            Navigator.pushNamed(context, 'ran_result');
            setState(() {
              if (isMultipleChoice) {
                // Pag confirm sa multiple choice, lilipat sa identification
                isMultipleChoice = false;
              } else {
                // Pag submit sa identification, dito papasok ang result logic
                print("Final Answer: ${_answerController.text}");
              }
            });
          },
          child: Text(isMultipleChoice ? "Confirm Answer" : "Submit Answer", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}