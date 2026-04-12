import 'package:equatable/equatable.dart';
import '../../../data/models/submission_model.dart';

sealed class SubmissionsState extends Equatable {
  const SubmissionsState();

  @override
  List<Object?> get props => [];
}

class SubmissionsInitial extends SubmissionsState {
  const SubmissionsInitial();
}

class SubmissionsLoading extends SubmissionsState {
  const SubmissionsLoading();
}

class SubmissionsLoaded extends SubmissionsState {
  final List<SubmissionModel> submissions;

  const SubmissionsLoaded(this.submissions);

  @override
  List<Object?> get props => [submissions];
}

class SubmissionsError extends SubmissionsState {
  final String message;

  const SubmissionsError(this.message);

  @override
  List<Object?> get props => [message];
}
