import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const CreateUploadPage(),
      // Route para sa create page pagkatapos ng upload
      'create': (context) => const Scaffold(
            body: Center(
              child: Text(
                "Create Page Content Here",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
    },
  ));
}

class CreateUploadPage extends StatefulWidget {
  const CreateUploadPage({super.key});

  @override
  State<CreateUploadPage> createState() => _CreateUploadPageState();
}

class _CreateUploadPageState extends State<CreateUploadPage> {
  // Theme Colors
  final Color colorDominant = const Color(0xFF665FBE); // Violet
  final Color colorSecondary = const Color(0xFFF8F2FF);
  final Color colorAccent = const Color(0xFFFF7A00); // Orange
  final Color colorSuccessIcon = const Color(0xFF3CD288);

  PlatformFile? selectedFile;
  bool isUploading = false;
  bool isUploaded = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        isUploaded = false; // Reset status kapag nagpalit ng file
      });
    }
  }

  void handleUpload() {
    if (selectedFile == null) return;
    setState(() => isUploading = true);

    // Simulate upload delay (2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isUploading = false;
          isUploaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSecondary,
      appBar: AppBar(
        backgroundColor: colorDominant,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Upload Document",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // --- FILE DETAILS/UPLOAD AREA ---
                    if (isUploaded) ...[
                      // Success View
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorSecondary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.description,
                                  color: colorDominant, size: 35),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedFile?.name ?? "Document_File.pdf",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: colorDominant),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${((selectedFile?.size ?? 0) / (1024 * 1024)).toStringAsFixed(1)} MB Â· ${selectedFile?.extension?.toUpperCase() ?? 'FILE'}",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle,
                                color: colorSuccessIcon, size: 28),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Selection View
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: selectedFile != null
                                ? colorDominant
                                : colorDominant.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorSecondary.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedFile != null
                                    ? Icons.insert_drive_file
                                    : Icons.cloud_upload_outlined,
                                size: 50,
                                color: colorDominant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              selectedFile != null
                                  ? selectedFile!.name
                                  : "Upload your file",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap the button below to choose\na file from your device",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: pickFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorDominant,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(selectedFile != null
                                  ? "Change File"
                                  : "Choose File"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Format Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ["PDF", "DOCX", "JPG"]
                            .map((txt) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: colorDominant.withOpacity(0.1),
                                        width: 1),
                                  ),
                                  child: Text(
                                    txt,
                                    style: TextStyle(
                                      color: colorDominant.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],

                    const Spacer(),

                    // --- MAIN ACTION BUTTON (ORANGE & NAVIGATE) ---
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (selectedFile == null || isUploading)
                            ? null
                            : () {
                                if (isUploaded) {
                            
                                 if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                  
                                    Navigator.pushReplacementNamed(context, '/');
                                  }
                                } else {
                                  handleUpload();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccent, // Always Orange
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isUploaded ? "Done" : "Upload Now",
                                
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}