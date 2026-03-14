class AppUser {
    final String userId;
    String? username;
    final String email;
    final String provider;
    final String? photoUrl;
    int streak;
   

    AppUser({
        required this.userId,
        this.username,
        required this.email,
        this.provider = 'password',
        this.photoUrl,
        this.streak = 0,
    });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      userId: id,
      username: data['username'],
      email: data['email'] ?? '',
      provider: data['provider'] ?? 'password',
      photoUrl: data['photoUrl'],
      streak: data['streak'] ?? 0,
       );
  }

   Map<String, dynamic> toMap() {
    return {
      'userId' : userId,
      'username': username,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
      'streak': streak,
    };
  }
}