class UpdatePasswordModel {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordModel({
    required this.currentPassword,
    required this.newPassword,
  });

  bool isValid() {
    return currentPassword.length >= 8 && newPassword.length >= 8;
  }

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
