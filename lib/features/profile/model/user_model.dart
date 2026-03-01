class user {
    final String userId;
    final String username;
    final String emailAdd;
   

    user({
        required this.userId,
        required this.username,
        required this.emailAdd,
    });

  factory user.fromMap(String id, Map<String, dynamic> data) {
    return user(
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