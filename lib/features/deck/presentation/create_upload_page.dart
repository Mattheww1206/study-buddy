import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: CreateUploadPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class CreateUploadPage extends StatefulWidget {
  const CreateUploadPage({super.key});

  @override
  State<CreateUploadPage> createState() => _CreateUploadPageState();
}

class _CreateUploadPageState extends State<CreateUploadPage> {
  // Colors batay sa screenshot
  final Color colorDominant = const Color(0xFF2D2B75); // Dark Blue/Purple Header
  final Color colorSecondary = const Color(0xFFF3E8FF); // Light Purple background
  final Color colorAccent = const Color(0xFFFF7A00);   // Orange button
  final Color colorSuccessBg = const Color(0xFFE8FDF2); // Light Green success
  final Color colorSuccessText = const Color(0xFF1B8A5A); // Dark Green text
  final Color colorSuccessIcon = const Color(0xFF3CD288); // Bright Green icon

  PlatformFile? selectedFile;
  bool isUploading = false;
  bool isUploaded = false;

  // Function para pumili ng file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        isUploaded = false; // Reset kung kumuha ng bagong file
      });
    }
  }

  // Simulation ng upload process
  void handleUpload() {
    setState(() => isUploading = true);

    // Nag-aadd tayo ng konting delay para kunwari nag-uupload
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isUploading = false;
        isUploaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorDominant,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Upload File",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Dark Header Extension
          Container(
            height: 20,
            width: double.infinity,
            color: colorDominant,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // --- KUNG SUCCESSFUL ANG UPLOAD ---
                  if (isUploaded) ...[
                    // Success Message Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorSuccessBg,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorSuccessIcon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upload Successful!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorSuccessText,
                                ),
                              ),
                              Text(
                                "Your file has been uploaded.",
                                style: TextStyle(color: colorSuccessText.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // File Details Card (Biology_Notes.pdf style)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.green.withOpacity(0.1), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorSuccessBg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.description, color: Colors.grey.shade400, size: 35),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFile?.name ?? "No_File.pdf",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2D2B75)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB · PDF",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          // Done Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorSuccessBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 16, color: colorSuccessText),
                                const SizedBox(width: 4),
                                Text(
                                  "Done",
                                  style: TextStyle(color: colorSuccessText, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] 
                  
                  // --- KUNG WALA PA O NAGPI-PICK PA LANG ---
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5FF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selectedFile != null ? colorAccent : Colors.deepPurple.shade50,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              selectedFile != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                              size: 50,
                              color: colorDominant,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            selectedFile != null ? selectedFile!.name : "Upload your file",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Tap the button below to choose\na file from your device",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: pickFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorDominant,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(selectedFile != null ? "Change File" : "Choose File"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Format Tags
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["PDF", "DOCX", "DOC"].map((txt) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(txt, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      )).toList(),
                    ),
                    const SizedBox(height: 40),
                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (selectedFile == null || isUploading) ? null : handleUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccent,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: isUploading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Upload", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}