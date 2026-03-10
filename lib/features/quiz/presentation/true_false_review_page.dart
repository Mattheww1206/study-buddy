import 'package:flutter/material.dart';

class TrueFalseReviewPage extends StatefulWidget {
  const TrueFalseReviewPage({super.key});

  @override
  State<TrueFalseReviewPage> createState() => _TrueFalseReviewPageState();
}

class _TrueFalseReviewPageState extends State<TrueFalseReviewPage> {
  // Palette settings (Consistent sa Multiple Review Page)
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFF665FBE);

  // Sample data para sa True/False
  final List<Map<String, dynamic>> tfReviewData = [
    {
      "isCorrect": false,
      "question": "The sun rises in the West.",
      "userAnswer": "True",
      "correctAnswer": "False",
    },
    {
      "isCorrect": false,
      "question": "Flutter is developed by Facebook.",
      "userAnswer": "True",
      "correctAnswer": "False",
    },
    {
      "isCorrect": true, // Hindi ito lalabas dahil naka-filter tayo sa 'false'
      "question": "Water boils at 100 degrees Celsius.",
      "userAnswer": "True",
      "correctAnswer": "True",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter para 'false' (mali) lang ang makuha
    final incorrectAnswers = tfReviewData.where((item) => item['isCorrect'] == false).toList();

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
          'T/F Review Results',
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
                'Incorrect Answers:',
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
                              const Icon(Icons.cancel, color: Colors.red, size: 28),
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
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: dominantColor.withOpacity(0.7),
                                          ),
                                          children: [
                                            const TextSpan(text: "Your Answer: "),
                                            TextSpan(
                                              text: item['userAnswer'],
                                              style: TextStyle(
                                                color: dominantColor,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: dominantColor.withOpacity(0.7),
                                          ),
                                          children: [
                                            const TextSpan(text: "Correct Answer: "),
                                            TextSpan(
                                              text: item['correctAnswer'],
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                              ),
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

                        // --- FOOTER STATUS BAR ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          color: accentColor,
                          child: const Text(
                            'True or False - Incorrect',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
}