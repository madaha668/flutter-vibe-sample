
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: (json['full_name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
      };

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName;
  }

  @override
  int get hashCode => Object.hash(id, email, fullName);
}

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  AuthTokens copyWith({String? access, String? refresh}) {
    return AuthTokens(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
    );
  }
}

class AuthSession {
  const AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;
}
