import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import './encryption.dart'; // Import the RSAEncryption class

/// ShowImageScreen displays the captured image and its encrypted blob data.
class ShowImageScreen extends StatefulWidget {
  final String imageBlobData;

  // Constructor to pass the image blob data to this screen
  const ShowImageScreen({super.key, required this.imageBlobData});

  @override
  _ShowImageScreenState createState() => _ShowImageScreenState();
}

class _ShowImageScreenState extends State<ShowImageScreen> {
  late String encryptedBlobData;
  late String publicKey; // Public key only
  late String privateKey; // Private key used for encryption (no decryption needed here)
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeKeys();
  }

  // Initialize the keys (private key is securely stored)
  Future<void> _initializeKeys() async {
    // Retrieve the public and private keys from secure storage
    publicKey = await secureStorage.read(key: 'public_key') ?? '';
    privateKey = await secureStorage.read(key: 'private_key') ?? '';

    if (publicKey.isEmpty || privateKey.isEmpty) {
      // If keys are not stored yet, generate and store them securely
      RSAEncryption rsaEncryption = RSAEncryption();
      publicKey = rsaEncryption.publicKey;
      privateKey = rsaEncryption.privateKey;

      // Store keys securely on the device
      await secureStorage.write(key: 'public_key', value: publicKey);
      await secureStorage.write(key: 'private_key', value: privateKey);
    }

    // Encrypt the image blob data
    RSAEncryption rsaEncryption = RSAEncryption();
    encryptedBlobData = rsaEncryption.encryptText(widget.imageBlobData.substring(0, 20));
  }

  // Function to show a dialog with the provided data
  void _showDataDialog(BuildContext context, String title, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              data,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              softWrap: true, // Allow text to wrap
              overflow: TextOverflow.visible, // Prevent overflow
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for private key access denial
  void _showPrivateKeyAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Private Key Access Denied"),
          content: const Text("You do not have access to the private key."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        base64Decode(widget.imageBlobData),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Button to show Full Blob Data
              ElevatedButton(
                onPressed: () {
                  _showDataDialog(context, "Full Blob Data", widget.imageBlobData);
                },
                child: const Text("Show Full Blob Data"),
              ),
              const SizedBox(height: 10),
              // Button to show Encrypted Data
              ElevatedButton(
                onPressed: () {
                  _showDataDialog(context, "Encrypted Data", encryptedBlobData);
                },
                child: const Text("Show Encrypted Data"),
              ),
              const SizedBox(height: 10),
              // Button to show Public Key
              ElevatedButton(
                onPressed: () {
                  _showDataDialog(context, "Public Key", publicKey);
                },
                child: const Text("Show Public Key"),
              ),
              const SizedBox(height: 10),
              // Button to show Private Key with restricted access
              ElevatedButton(
                onPressed: () {
                  _showPrivateKeyAccessDeniedDialog(context); // Deny access to private key
                },
                child: const Text("Show Private Key"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
