import 'package:flutter/material.dart';

class IdentificationReviewPage extends StatefulWidget {
  const IdentificationReviewPage({super.key});

  @override
  State<IdentificationReviewPage> createState() => _IdentificationReviewPageState();
}

class _IdentificationReviewPageState extends State<IdentificationReviewPage> {
  // Palette settings (Consistent sa Multiple Choice)
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFF665FBE);

  // Sample data para sa Identification (Karaniwang text-based ang sagot dito)
  final List<Map<String, dynamic>> identificationData = [
    {
      "isCorrect": false,
      "question": "What is the capital city of the Philippines?",
      "userAnswer": "Quezon City",
      "correctAnswer": "Manila",
    },
    {
      "isCorrect": false,
      "question": "Who is the national hero of the Philippines?",
      "userAnswer": "Andres Bonifacio",
      "correctAnswer": "Jose Rizal",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter para sa maling sagot lang
    final incorrectAnswers = identificationData.where((item) => item['isCorrect'] == false).toList();

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
          'Identification Review',
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
                'Review Errors:', 
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dominantColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: incorrectAnswers.length, 
                itemBuilder: (context, index) {
                  final item = incorrectAnswers[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
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
                              const Icon(Icons.help_outline, color: Colors.orange, size: 28),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  item['question'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dominantColor,
                                  ),
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
                              // User's Input
                              _buildAnswerBox(
                                label: "Your Answer: ",
                                value: item['userAnswer'],
                                icon: Icons.close,
                                iconColor: Colors.red,
                                boxColor: const Color(0xFFFDEEFF),
                              ),
                              const SizedBox(height: 10),
                              // Correct Answer
                              _buildAnswerBox(
                                label: "Correct Answer: ",
                                value: item['correctAnswer'],
                                icon: Icons.check,
                                iconColor: Colors.green,
                                boxColor: const Color(0xFFF3F2FF),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- FOOTER STATUS BAR ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          color: const Color(0xFF5E5CE6), // Pwede ring accentColor
                          child: const Text(
                            'Keep studying!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
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

  // Helper widget para hindi paulit-ulit ang code sa answer boxes
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
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: dominantColor.withOpacity(0.7),
                ),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: dominantColor,
                      fontWeight: FontWeight.bold,
                    ),
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