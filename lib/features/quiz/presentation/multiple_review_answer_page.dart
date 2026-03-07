import 'package:flutter/material.dart';

class MultipleReviewAnswerPage extends StatefulWidget {
  const MultipleReviewAnswerPage({super.key});

  @override
  State<MultipleReviewAnswerPage> createState() => _MultipleReviewAnswerPageState();
}

class _MultipleReviewAnswerPageState extends State<MultipleReviewAnswerPage> {
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFF665FBE);

  // Sample data: Siguraduhing may 'userAnswerIndex' at 'correctAnswerIndex'
  final List<Map<String, dynamic>> reviewData = [
    {
      "isCorrect": false,
      "question": "Who invented the telephone?",
      "userAnswer": "Thomas Edison",
      "userAnswerIndex": 2, // Ito ang magiging 'C'
      "correctAnswer": "Alexander Graham Bell",
      "correctAnswerIndex": 0, // Ito ang magiging 'A'
    },
    {
      "isCorrect": false,
      "question": "What is 5 + 5?",
      "userAnswer": "12",
      "userAnswerIndex": 1, // B
      "correctAnswer": "10",
      "correctAnswerIndex": 2, // C
    },
  ];

  @override
  Widget build(BuildContext context) {
    final incorrectAnswers = reviewData.where((item) => item['isCorrect'] == false).toList();

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
          'Review Results',
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
                'Wrong Answers:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dominantColor),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: incorrectAnswers.length,
                itemBuilder: (context, index) {
                  final item = incorrectAnswers[index];

                  // --- SAFE LETTER LOGIC ---
                  // Kung walang index na binigay, default sa '?' para hindi mag-error
                  String userLetter = item['userAnswerIndex'] != null 
                      ? String.fromCharCode(65 + (item['userAnswerIndex'] as int)) 
                      : "?";
                  
                  String correctLetter = item['correctAnswerIndex'] != null 
                      ? String.fromCharCode(65 + (item['correctAnswerIndex'] as int)) 
                      : "?";

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
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.cancel, color: Colors.red, size: 28),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  item['question'] ?? "No Question",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dominantColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // User's Choice
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDEEFF),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 15, color: dominantColor.withOpacity(0.7)),
                                          children: [
                                            const TextSpan(text: "Your Answer: "),
                                            TextSpan(
                                              text: "$userLetter. ${item['userAnswer'] ?? ''}", 
                                              style: TextStyle(color: dominantColor, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.close, color: Colors.red, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Correct Answer
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F2FF),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 15, color: dominantColor.withOpacity(0.7)),
                                          children: [
                                            const TextSpan(text: "Correct Answer: "),
                                            TextSpan(
                                              text: "$correctLetter. ${item['correctAnswer'] ?? ''}",
                                              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.check, color: Colors.green, size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          color: accentColor,
                          child: const Text(
                            'Incorrect',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}