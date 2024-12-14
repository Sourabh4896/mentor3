import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/pointycastle.dart';
import './../../secure_key_storage.dart';  // Import the secure storage file

class RSAEncryption {
  late pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey> _keyPair;
  String _publicKey = "";
  String _privateKey = "";

  // Fixed seed components for key generation
  static const String SMARTPHONE_ID = "1234567890"; // Example smartphone ID
  static const String HUID = "HUID123456";          // Example HUID

  final SecureKeyStorage _secureKeyStorage = SecureKeyStorage();

  RSAEncryption() {
    _loadKeys();  // Load keys if stored
    if (_publicKey.isEmpty || _privateKey.isEmpty) {
      _refreshKeyPair(); // Generate new keys if none found
    }
  }

  /// Load RSA Keys from secure storage
  Future<void> _loadKeys() async {
    _publicKey = await _secureKeyStorage.getPublicKey() ?? "";
    _privateKey = await _secureKeyStorage.getPrivateKey() ?? "";
  }

  /// Generate RSA Key Pair
  pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey> _generateKeyPair() {
    final seedInput = utf8.encode(SMARTPHONE_ID + HUID + Random().nextInt(1000).toString());
    final sha256 = SHA256Digest();
    final seed = sha256.process(Uint8List.fromList(seedInput));

    final secureRandom = FortunaRandom()..seed(pc.KeyParameter(seed));

    final keyParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);
    final generator = RSAKeyGenerator()..init(pc.ParametersWithRandom(keyParams, secureRandom));

    return generator.generateKeyPair();
  }

  /// Refresh RSA Key Pair and store securely
  Future<void> _refreshKeyPair() async {
    _keyPair = _generateKeyPair();
    _publicKey = _formatPublicKey(_keyPair.publicKey as RSAPublicKey);
    _privateKey = _formatPrivateKey(_keyPair.privateKey as RSAPrivateKey);
    
    // Store keys securely in the secure storage
    await _secureKeyStorage.storeKeys(_publicKey, _privateKey);
  }

  /// Format Public Key for Display
  String _formatPublicKey(RSAPublicKey publicKey) {
    return "Modulus: ${publicKey.modulus}\nExponent: ${publicKey.exponent}";
  }

  /// Format Private Key for Display
  String _formatPrivateKey(RSAPrivateKey privateKey) {
    return "Modulus: ${privateKey.modulus}\nExponent: ${privateKey.exponent}";
  }

  /// RSA-OAEP Encryption
  Uint8List rsaOaepEncrypt(RSAPublicKey publicKey, String plaintext) {
    final oaepEncoding = OAEPEncoding(pc.AsymmetricBlockCipher("RSA/PKCS1"))
      ..init(true, pc.PublicKeyParameter<RSAPublicKey>(publicKey));

    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    return oaepEncoding.process(plaintextBytes);
  }

  /// Encrypt the given text using RSA and return the encrypted base64 encoded string
  String encryptText(String plaintext) {
    final encryptedBytes = rsaOaepEncrypt(_keyPair.publicKey as RSAPublicKey, plaintext);
    return base64Encode(encryptedBytes);
  }

  String get publicKey => _publicKey;
  String get privateKey => _privateKey;

  // Testing the secure environment
  Future<void> testKeyAccess() async {
    String? publicKey = await _secureKeyStorage.getPublicKey();
    String? privateKey = await _secureKeyStorage.getPrivateKey();
    
    if (publicKey != null && privateKey != null) {
      print('Keys are securely stored and accessible only to the app.');
    } else {
      print('Keys could not be accessed, indicating proper security.');
    }
  }
}
