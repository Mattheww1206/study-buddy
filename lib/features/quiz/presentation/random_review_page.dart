import 'package:flutter/material.dart';

class RandomReviewPage extends StatefulWidget {
  const RandomReviewPage({super.key});

  @override
  State<RandomReviewPage> createState() => _RandomReviewPageState();
}

class _RandomReviewPageState extends State<RandomReviewPage> {
  // Palette settings
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);

  // Sample Mixed Data
  final List<Map<String, dynamic>> randomReviewData = [
    {
      "type": "multiple", // Type indicator
      "isCorrect": false,
      "question": "Who created the World Wide Web (WWW)?",
      "userAnswer": "Steve Jobs",
      "userAnswerIndex": 2, // Choice index (C)
      "correctAnswer": "Tim Berners-Lee",
      "correctAnswerIndex": 0, // Choice index (A)
    },
    {
      "type": "identification",
      "isCorrect": false,
      "question": "What is the capital city of the Philippines?",
      "userAnswer": "Quezon City",
      "correctAnswer": "Manila",
      "userAnswerIndex": null, 
      "correctAnswerIndex": null,
    },
  ];

  // Helper function para makuha ang Letter (A, B, C...)
  String getLetter(int? index) {
    if (index == null) return ""; // Pag Identification, walang letter
    return "${String.fromCharCode(65 + index)}. "; // 65 is 'A'
  }

  @override
  Widget build(BuildContext context) {
    final incorrectAnswers = randomReviewData.where((item) => item['isCorrect'] == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Random Review',
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                'Review Mistakes:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dominantColor),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: incorrectAnswers.length,
                itemBuilder: (context, index) {
                  final item = incorrectAnswers[index];
                  final bool isMultiple = item['type'] == 'multiple';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // --- QUESTION SECTION ---
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isMultiple ? Icons.list_alt : Icons.edit_note,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  item['question'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dominantColor),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- ANSWER BOXES ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // User's Answer
                              _buildAnswerBox(
                                label: "Your Answer: ",
                                // Dito ikakabit ang Letter + Text
                                value: "${getLetter(item['userAnswerIndex'])}${item['userAnswer']}",
                                icon: Icons.close,
                                iconColor: Colors.red,
                                boxColor: const Color(0xFFFDEEFF),
                              ),
                              const SizedBox(height: 10),
                              // Correct Answer
                              _buildAnswerBox(
                                label: "Correct Answer: ",
                                // Dito ikakabit ang Letter + Text
                                value: "${getLetter(item['correctAnswerIndex'])}${item['correctAnswer']}",
                                icon: Icons.check,
                                iconColor: Colors.green,
                                boxColor: const Color(0xFFF3F2FF),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- FOOTER ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          color: isMultiple ? dominantColor : const Color(0xFF5E5CE6),
                          child: Text(
                            isMultiple ? 'MULTIPLE CHOICE' : 'IDENTIFICATION',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget 
  Widget _buildAnswerBox({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color boxColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: dominantColor.withOpacity(0.7)),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: dominantColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}