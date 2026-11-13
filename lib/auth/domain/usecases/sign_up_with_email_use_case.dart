import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/auth/domain/repositories/auth_repository.dart';
import 'package:inveio/auth/domain/usecases/params/user_details_params.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for signing up a new user with email and password.
class SignUpWithEmailUseCase {
  /// The repository used for authentication operations.
  final AuthRepository userRepository;

  /// Creates a [SignUpWithEmailUseCase] with the given [AuthRepository].
  SignUpWithEmailUseCase({required this.userRepository});

  /// Executes the sign-up use case with the provided [params].
  Future<Either<Failure, UserEntity>> call({
    required UserDetailsParams params,
  }) async {
    final user = UserEntity(
      name: params.name,
      email: params.email,
      phone: params.phone,
      photoUrl: params.photoUrl,
      uid: null,
    );
    return await userRepository.createUser(
      userDetails: user,
      password: params.password,
    );
  }
}
