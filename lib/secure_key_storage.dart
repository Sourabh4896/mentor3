import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStorage {
  final _secureStorage = FlutterSecureStorage();

  // Keys to store in secure storage
  static const String publicKeyKey = 'public_key';
  static const String privateKeyKey = 'private_key';

  // Store keys securely in the secure storage
  Future<void> storeKeys(String publicKey, String privateKey) async {
    await _secureStorage.write(key: publicKeyKey, value: publicKey);
    await _secureStorage.write(key: privateKeyKey, value: privateKey);
  }

  // Retrieve the public key securely from storage
  Future<String?> getPublicKey() async {
    return await _secureStorage.read(key: publicKeyKey);
  }

  // Retrieve the private key securely from storage
  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: privateKeyKey);
  }

  // Delete all keys from secure storage
  Future<void> deleteKeys() async {
    await _secureStorage.delete(key: publicKeyKey);
    await _secureStorage.delete(key: privateKeyKey);
  }
}
