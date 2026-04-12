import 'package:equatable/equatable.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/submission_model.dart';

class SubmissionDetailState extends Equatable {
  final bool loading;
  final SubmissionModel? submission;
  final CodeReviewModel? review;
  final String? errorMessage;
  final bool submittingAction;
  final String? actionMessage;

  const SubmissionDetailState({
    this.loading = false,
    this.submission,
    this.review,
    this.errorMessage,
    this.submittingAction = false,
    this.actionMessage,
  });

  SubmissionDetailState copyWith({
    bool? loading,
    SubmissionModel? submission,
    CodeReviewModel? review,
    String? errorMessage,
    bool? submittingAction,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return SubmissionDetailState(
      loading: loading ?? this.loading,
      submission: submission ?? this.submission,
      review: review ?? this.review,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittingAction: submittingAction ?? this.submittingAction,
      actionMessage:
          clearActionMessage ? null : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submission,
        review,
        errorMessage,
        submittingAction,
        actionMessage,
      ];
}
