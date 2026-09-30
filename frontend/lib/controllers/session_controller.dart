import 'package:get/get.dart';

class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;
}

class SessionController extends GetxController {
  final Rxn<SessionUser> currentUser = Rxn<SessionUser>();

  SessionUser get user =>
      currentUser.value ??
      const SessionUser(
        name: 'Site Manager',
        email: 'manager@constructionsite.com',
        role: 'Project Manager',
      );

  void setMockUser({String? name, String? email}) {
    currentUser.value = SessionUser(
      name: (name == null || name.trim().isEmpty)
          ? 'Jay Bagdane'
          : name.trim(),
      email: (email == null || email.trim().isEmpty)
          ? 'manager@constructionsite.com'
          : email.trim(),
      role: 'Project Manager',
    );
  }

  void clearSession() {
    currentUser.value = null;
  }
}
