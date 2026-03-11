class AppUser {
    final String userId;
    String? username;
    final String email;
    final String provider;
    final String? photoUrl;
   

    AppUser({
        required this.userId,
        this.username,
        required this.email,
        this.provider = 'password',
        this.photoUrl
    });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      userId: id,
      username: data['username'],
      email: data['email'] ?? '',
      provider: data['provider'] ?? 'password',
      photoUrl: data['photoUrl'],
       );
  }

   Map<String, dynamic> toMap() {
    return {
      'userId' : userId,
      'username': username,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
    };
  }
}