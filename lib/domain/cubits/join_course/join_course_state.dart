import 'package:equatable/equatable.dart';

sealed class JoinCourseState extends Equatable {
  const JoinCourseState();

  @override
  List<Object?> get props => [];
}

class JoinCourseIdle extends JoinCourseState {
  const JoinCourseIdle();
}

class JoinCourseSubmitting extends JoinCourseState {
  const JoinCourseSubmitting();
}

class JoinCourseSuccess extends JoinCourseState {
  const JoinCourseSuccess();
}

class JoinCourseError extends JoinCourseState {
  final String message;

  const JoinCourseError(this.message);

  @override
  List<Object?> get props => [message];
}
