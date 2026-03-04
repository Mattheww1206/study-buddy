class AppUser {
    final String userId;
    String? username;
    final String emailAdd;
    final String provider;
   

    AppUser({
        required this.userId,
        this.username,
        required this.emailAdd,
        this.provider = 'password',
    });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      userId: id,
      username: data['username'],
      emailAdd: data['email'] ?? '',
      provider: data['provider'] ?? 'password',
       );
  }

   Map<String, dynamic> toMap() {
    return {
      'userId' : userId,
      'username': username,
      'email': emailAdd,
      'provider': provider,
    };
  }
}