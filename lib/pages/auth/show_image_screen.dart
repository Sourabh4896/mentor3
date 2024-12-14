import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding
import './encryption.dart'; // Import the RSAEncryption class

/// ShowImageScreen displays the captured image and its encrypted blob data.
class ShowImageScreen extends StatelessWidget {
  final String imageBlobData;

  // Constructor to pass the image blob data to this screen
  const ShowImageScreen({super.key, required this.imageBlobData});

  @override
  Widget build(BuildContext context) {
    // Instantiate the RSAEncryption class to encrypt the blob data
    RSAEncryption rsaEncryption = RSAEncryption();

    // Encrypt the image blob data and limit it to 100 characters
    String encryptedBlobData = rsaEncryption.encryptText(imageBlobData.substring(0, 20));

    // Limit the blob data to 100 characters
    String limitedImageBlobData = imageBlobData.length > 100 ? imageBlobData.substring(0, 100) : imageBlobData;
    String limitedEncryptedBlobData = encryptedBlobData.length > 100 ? encryptedBlobData.substring(0, 100) : encryptedBlobData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Captured Image label with improved styling
              const AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Text(
                  'Captured Image:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Image container with shadows and rounded corners
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Image.memory(
                        base64Decode(imageBlobData),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Encrypted Blob Data label with smooth fade-in
              const AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Text(
                  'Encrypted Blob Data :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Encrypted data with wrapping text and custom padding
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width), // Ensure text doesn't overflow
                    child: Text(
                      limitedEncryptedBlobData, // Limited encrypted data
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      softWrap: true, // Allow text to wrap
                      overflow: TextOverflow.visible, // Prevent overflow
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Full Blob Data label with smooth fade-in
              const AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Text(
                  'Full Blob Data:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Full encrypted data with wrapping text and custom padding
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width), // Ensure text doesn't overflow
                    child: Text(
                      limitedImageBlobData, // Limited full data
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      softWrap: true, // Allow text to wrap
                      overflow: TextOverflow.visible, // Prevent overflow
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
