part of 'export_data_cubit.dart';

/// Base class for all export data states.
sealed class ExportDataState extends Equatable {
  const ExportDataState();

  @override
  List<Object?> get props => [];
}

/// The initial, idle state.
final class ExportDataInitial extends ExportDataState {
  const ExportDataInitial();
}

/// The export is currently running.
final class ExportDataInProgress extends ExportDataState {
  const ExportDataInProgress();
}

/// The export finished and wrote a file at [filePath].
final class ExportDataSuccess extends ExportDataState {
  final String filePath;

  const ExportDataSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// The export failed with [message].
final class ExportDataFailure extends ExportDataState {
  final String message;

  const ExportDataFailure(this.message);

  @override
  List<Object?> get props => [message];
}
