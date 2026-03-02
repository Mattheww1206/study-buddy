class appUser {
    final String userId;
    final String username;
    final String emailAdd;
   

    appUser({
        required this.userId,
        required this.username,
        required this.emailAdd,
    });

  factory appUser.fromMap(String id, Map<String, dynamic> data) {
    return appUser(
      userId: id,
      username: data['username'] ?? '',
      emailAdd: data['emailAdd'] ?? ''
       );
  }

   Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': emailAdd,
    };
  }
}