import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for onboarding data, backed by SharedPreferences.
class OnboardingLocalDataSource {
  final SharedPreferences _prefs;

  /// Creates an [OnboardingLocalDataSource] with the given [prefs] instance.
  OnboardingLocalDataSource({required SharedPreferences prefs})
    : _prefs = prefs;

  static const _businessNameKey = 'onboarding_business_name';
  static const _addressKey = 'onboarding_address';
  static const _logoPathKey = 'onboarding_logo_path';
  static const _gstinKey = 'onboarding_gstin';
  static const _gstinStatusKey = 'onboarding_gstin_status';
  static const _workTypeKey = 'onboarding_work_type';
  static const _stateCodeKey = 'onboarding_state_code';
  static const _completeKey = 'onboarding_complete';

  /// Returns the saved business name, or `null` if none has been saved.
  String? getBusinessName() => _prefs.getString(_businessNameKey);

  /// Returns the saved business address, or `null` if none has been saved.
  String? getAddress() => _prefs.getString(_addressKey);

  /// Returns the saved logo path, or `null` if none has been saved.
  String? getLogoPath() => _prefs.getString(_logoPathKey);

  /// Returns the saved GSTIN, or `null` if none has been saved.
  String? getGstin() => _prefs.getString(_gstinKey);

  /// Returns the saved GST registration status name, or `null`.
  String? getGstinStatus() => _prefs.getString(_gstinStatusKey);

  /// Returns the saved work type name, or `null`.
  String? getWorkType() => _prefs.getString(_workTypeKey);

  /// Returns the saved state code, or `null` if none has been saved.
  Future<String?> getStateCode() async {
    return _prefs.getString(_stateCodeKey);
  }

  /// Persists the business [name] locally.
  Future<void> saveBusinessName(String name) async {
    await _prefs.setString(_businessNameKey, name);
  }

  /// Persists the business [address] locally.
  Future<void> saveAddress(String address) async {
    await _prefs.setString(_addressKey, address);
  }

  /// Persists the business logo [path] locally.
  Future<void> saveLogoPath(String path) async {
    await _prefs.setString(_logoPathKey, path);
  }

  /// Persists the GSTIN locally.
  Future<void> saveGstin(String gstin) async {
    await _prefs.setString(_gstinKey, gstin);
  }

  /// Persists the GST registration [status] locally.
  Future<void> saveGstinStatus(String status) async {
    await _prefs.setString(_gstinStatusKey, status);
  }

  /// Persists the state [code] locally.
  Future<void> saveStateCode(String code) async {
    await _prefs.setString(_stateCodeKey, code);
  }

  /// Persists the work [type] locally.
  Future<void> saveWorkType(String type) async {
    await _prefs.setString(_workTypeKey, type);
  }

  /// Marks the onboarding process as complete in local storage.
  Future<void> markComplete() async {
    await _prefs.setBool(_completeKey, true);
  }

  /// Returns `true` if onboarding has been marked complete.
  bool isComplete() {
    return _prefs.getBool(_completeKey) ?? false;
  }

  /// Removes all saved onboarding data from local storage.
  Future<void> clear() async {
    await _prefs.remove(_businessNameKey);
    await _prefs.remove(_addressKey);
    await _prefs.remove(_logoPathKey);
    await _prefs.remove(_gstinKey);
    await _prefs.remove(_gstinStatusKey);
    await _prefs.remove(_workTypeKey);
    await _prefs.remove(_stateCodeKey);
    await _prefs.remove(_completeKey);
  }
}
