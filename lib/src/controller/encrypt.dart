import 'package:encrypt/encrypt.dart' as encrypt;

String encryptPassword(String password) {
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(password, iv: iv);
  return encrypted.base64;
}


String password1 = encryptPassword('anubhav18');
