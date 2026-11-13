import 'dart:async';

import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/usecases/create_onboarding_status_use_case.dart';
import 'package:inveio/onboarding/domain/usecases/save_onboarding_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// BLoC that manages the onboarding flow state and events.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// The use case for persisting onboarding data.
  StreamSubscription? _authSubscription;
  final SaveOnboardingUseCase _saveUsecase;
  final CheckOnboardingStatusUseCase _checkUsecase;

  /// Creates an [OnboardingBloc] with the given save use case.
  OnboardingBloc({
    required SaveOnboardingUseCase saveOnboardingUsecase,
    required CheckOnboardingStatusUseCase checkUsecase,
    required AuthBloc authBloc,
  }) : _checkUsecase = checkUsecase,
       _saveUsecase = saveOnboardingUsecase,
       super(const OnboardingUnknown(OnboardingEntity.empty())) {
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthSignedIn) {
        add(CheckOnboardingStatus(authState.user.uid));
      }
    });

    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<BusinessNameChanged>(_onBusinessNameChanged);
    on<BusinessAddressChanged>(_onBusinessAddressChanged);
    on<BusinessLogoChanged>(_onBusinessLogoChanged);
    on<GstinChanged>(_onGstinChanged);
    on<WorkTypeSelected>(_onWorkTypeSelected);
    on<OnboardingSubmitted>(_onOnboardingSubmitted);
    on<GstRegistrationStatusSet>(_onGstRegistrationStatusSet);
  }
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await _checkUsecase(event.uid!);

    result.fold(
      (failure) => emit(OnboardingFailure(state.onboarding, failure.message)),
      (onboarding) => emit(OnboardingInitial(onboarding)),
    );
  }

  void _onBusinessNameChanged(
    BusinessNameChanged event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state.onboarding;
    emit(OnboardingInitial(current.copyWith(businessName: event.name)));
  }

  void _onBusinessAddressChanged(
    BusinessAddressChanged event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state.onboarding;
    emit(OnboardingInitial(current.copyWith(address: event.address)));
  }

  void _onBusinessLogoChanged(
    BusinessLogoChanged event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state.onboarding;
    emit(OnboardingInitial(current.copyWith(logoPath: event.logoPath)));
  }

  void _onGstinChanged(GstinChanged event, Emitter<OnboardingState> emit) {
    final current = state.onboarding;
    final code = event.gstin.length >= 2 ? event.gstin.substring(0, 2) : null;
    emit(
      OnboardingInitial(current.copyWith(gstin: event.gstin, stateCode: code)),
    );
  }

  void _onWorkTypeSelected(
    WorkTypeSelected event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state.onboarding;
    emit(OnboardingInitial(current.copyWith(workType: event.type)));
  }

  Future<void> _onOnboardingSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    final data = state.onboarding.copyWith(onboardingComplete: true);
    emit(OnboardingLoading(data));
    final result = await _saveUsecase(data);
    result.fold(
      (failure) => emit(OnboardingFailure(data, failure.message)),
      (_) => emit(OnboardingSuccess(data)),
    );
  }

  void _onGstRegistrationStatusSet(
    GstRegistrationStatusSet event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state.onboarding;
    emit(
      OnboardingInitial(
        current.copyWith(
          gstinStatus: event.status,
          gstin: event.status == GstinStatus.yes ? current.gstin : null,
          stateCode: event.status == GstinStatus.yes ? current.stateCode : null,
        ),
      ),
    );
  }
}
