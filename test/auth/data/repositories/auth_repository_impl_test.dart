import 'dart:io';

import 'package:inveio/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:inveio/auth/data/repositories/auth_repository_impl.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockAuthRemote;
  late MockUserRemoteDataSource mockUserRemote;
  late MockUserLocalDataSource mockUserLocal;
  final tUserModel = UserModel(
    uid: '1123123',
    name: 'testing',
    email: 'testing@gmail.com',
    isPro: false,
    createdAt: DateTime.now(),
  );
  setUp(() {
    mockAuthRemote = MockAuthRemoteDataSource();
    mockUserLocal = MockUserLocalDataSource();
    mockUserRemote = MockUserRemoteDataSource();
    repository = AuthRepositoryImpl(
      authRemoteDataSource: mockAuthRemote,
      userLocalDataSource: mockUserLocal,
      userRemoteDataSource: mockUserRemote,
    );
  });
  group('signInWithEmail', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password123';
    test('returns Right(UserEntity) when sign in succeed', () async {
      when(
        () =>
            mockAuthRemote.signInWithEmail(email: tEmail, password: tPassword),
      ).thenAnswer((_) async {});
      when(
        () => mockUserRemote.fetchProfile(),
      ).thenAnswer((_) async => tUserModel);
      when(
        () => mockUserLocal.saveProfile(tUserModel),
      ).thenAnswer((_) async {});
      final result = await repository.signInWithEmail(
        email: tEmail,
        password: tPassword,
      );
      result.match(
        (failure) => fail('Expected Right, got Left: $failure'),
        (user) => expect(user.uid, tUserModel.uid),
      );
      verify(() => mockUserLocal.saveProfile(tUserModel)).called(1);
    });
    test('returns Left(AuthFailure) when profile is null', () async {
      when(
        () =>
            mockAuthRemote.signInWithEmail(email: tEmail, password: tPassword),
      ).thenAnswer((_) async {});
      when(() => mockUserRemote.fetchProfile()).thenAnswer((_) async => null);
      final result = await repository.signInWithEmail(
        email: tEmail,
        password: tPassword,
      );
      expect(result, const Left(AuthFailure('User profile not found')));
      verifyNever(() => mockUserLocal.saveProfile(tUserModel));
    });

    test('returns Left(NetworkFailure) when no internet connection', () async {
      when(
        () =>
            mockAuthRemote.signInWithEmail(email: tEmail, password: tPassword),
      ).thenThrow(const SocketException('No internet'));
      final result = await repository.signInWithEmail(
        email: tEmail,
        password: tPassword,
      );
      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });
}
