import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user.
class AuthUserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;

  const AuthUserEntity({
    required this.uid,
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [uid, email, displayName];
}
