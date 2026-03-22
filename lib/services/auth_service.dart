import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Web OAuth client for browser login and mobile server client for Android/iOS.
  static const String _webClientId =
      '768159940383-571ibpdaitdtrra3am2p1r82sbc8k7ud.apps.googleusercontent.com';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(serverClientId: _webClientId);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        return _auth.signInWithPopup(provider);
      }

      final googleSignIn = _googleSignIn;
      if (googleSignIn == null) {
        throw Exception('Google Sign-In chua san sang tren thiet bi nay.');
      }

      // Ensure account chooser appears consistently when switching users.
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Khong lay duoc idToken tu Google. Vui long thu lai.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthException(e));
    } on PlatformException catch (e) {
      throw Exception(_handleGoogleSignInPlatformException(e));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<void> signOut() async {
    final googleSignIn = _googleSignIn;
    if (googleSignIn != null) {
      try {
        await googleSignIn.disconnect();
      } catch (_) {
        // Ignore: disconnect can fail if there is no previous Google session.
      }
    }

    if (googleSignIn != null) {
      await Future.wait([
        _auth.signOut(),
        googleSignIn.signOut(),
      ]);
      return;
    }

    await _auth.signOut();
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ.';
      case 'operation-not-allowed':
        return 'Đăng nhập Google chưa được bật trên Firebase Console.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      default:
        return e.message ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  String _handleGoogleSignInPlatformException(PlatformException e) {
    final raw = '${e.code} ${e.message ?? ''}'.toLowerCase();

    if (raw.contains('apiexception: 10') ||
        raw.contains('developer_error') ||
        raw.contains('sign_in_failed')) {
      return 'Dang nhap Google that bai do cau hinh OAuth tren thiet bi/build nay. '
          'Hay them SHA-1 va SHA-256 cua may build vao Firebase, sau do tai lai '
          'google-services.json va build lai ung dung.';
    }

    if (raw.contains('network_error') || raw.contains('network')) {
      return 'Khong the ket noi mang khi dang nhap. Vui long kiem tra Internet.';
    }

    return 'Dang nhap Google that bai: ${e.message ?? e.code}';
  }
}