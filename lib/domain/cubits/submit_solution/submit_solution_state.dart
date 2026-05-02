import 'package:equatable/equatable.dart';

sealed class SubmitSolutionState extends Equatable {
  const SubmitSolutionState();

  @override
  List<Object?> get props => [];
}

class SubmitSolutionIdle extends SubmitSolutionState {
  const SubmitSolutionIdle();
}

class SubmitSolutionSubmitting extends SubmitSolutionState {
  const SubmitSolutionSubmitting();
}

class SubmitSolutionSuccess extends SubmitSolutionState {
  const SubmitSolutionSuccess();
}

class SubmitSolutionError extends SubmitSolutionState {
  final String message;

  const SubmitSolutionError(this.message);

  @override
  List<Object?> get props => [message];
}
