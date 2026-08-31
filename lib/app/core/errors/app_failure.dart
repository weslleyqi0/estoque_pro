import 'package:equatable/equatable.dart';

/// Base class representing domain and infrastructure failures in the application.
sealed class AppFailure extends Equatable implements Exception {
  final String message;
  final String? code;
  final Object? error;
  final StackTrace? stackTrace;

  const AppFailure({
    required this.message,
    this.code,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, error];

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Failure representing connection issues, timeouts, or lack of internet connectivity.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'Sem conexão com a internet. Verifique sua conexão de rede.',
    super.code,
    super.error,
    super.stackTrace,
  });
}

/// Failure representing unauthorized access or permission denial (e.g. RBAC).
final class PermissionFailure extends AppFailure {
  const PermissionFailure({
    super.message = 'Você não tem permissão para realizar esta operação.',
    super.code,
    super.error,
    super.stackTrace,
  });
}

/// Failure representing a violation of domain or business rules.
final class BusinessRuleFailure extends AppFailure {
  const BusinessRuleFailure({
    required super.message,
    super.code,
    super.error,
    super.stackTrace,
  });
}

/// Failure representing that the requested entity or record was not found.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'O registro solicitado não foi encontrado.',
    super.code,
    super.error,
    super.stackTrace,
  });
}

/// Failure representing database errors or operation cancellations.
final class DatabaseFailure extends AppFailure {
  const DatabaseFailure({
    super.message = 'Erro ao realizar operação no banco de dados.',
    super.code,
    super.error,
    super.stackTrace,
  });
}

/// Fallback failure for unexpected or unhandled exceptions.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message = 'Ocorreu um erro inesperado.',
    super.code,
    super.error,
    super.stackTrace,
  });
}
