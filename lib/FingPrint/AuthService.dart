import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final RxBool isAuthenticating = false.obs;
  final RxString authError = ''.obs;

  Future<bool> checkBiometricSupport() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return canAuthenticate && availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric support: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      isAuthenticating.value = true;
      authError.value = '';

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'يرجى المسح البيومتري للدخول',
        biometricOnly: true,
      );

      isAuthenticating.value = false;
      return didAuthenticate;
    } catch (e) {
      isAuthenticating.value = false;
      authError.value = 'فشل المصادقة: ${e.toString()}';
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
    isAuthenticating.value = false;
  }
}