// import 'package:get/get.dart';
// import 'controller.dart';
//
// class FingerprintMiddleware extends GetMiddleware {
//   final FingerprintController _fingerprintController = Get.find();
//
//   @override
//   Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
//     if (route.currentPage!.name == '/fingerprint-settings' ||
//         route.currentPage!.name == '/login' ||
//         route.currentPage!.name == '/onboarding') {
//       return await super.redirectDelegate(route);
//     }
//
//
//     // التحقق من البصمة
//     final isAuthenticated = await _fingerprintController.checkOnAppStart();
//
//     if (!isAuthenticated && _fingerprintController.isFingerprintEnabled.value) {
//       // إعادة التوجيه إلى شاشة البصمة
//       return GetNavConfig.fromRoute('/fingerprint-auth');
//     }
//
//     return await super.redirectDelegate(route);
//   }
// }