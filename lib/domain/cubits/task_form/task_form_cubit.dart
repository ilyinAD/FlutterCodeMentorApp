import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'task_form_state.dart';

class TaskFormCubit extends Cubit<TaskFormState> {
  final TaskRepository _repository;

  TaskFormCubit(this._repository) : super(const TaskFormState());

  void addCriterion() {
    final updated = [
      ...state.criteria,
      const TaskCriteriaModel(
        criterionName: '',
        criterionDescription: '',
        weight: 10,
      ),
    ];
    emit(state.copyWith(criteria: updated));
  }

  void removeCriterion(int index) {
    if (index < 0 || index >= state.criteria.length) return;
    final updated = [...state.criteria]..removeAt(index);
    emit(state.copyWith(criteria: updated));
  }

  void updateCriterion(int index, TaskCriteriaModel criterion) {
    if (index < 0 || index >= state.criteria.length) return;
    final updated = [...state.criteria];
    updated[index] = criterion;
    emit(state.copyWith(criteria: updated));
  }

  Future<void> submit({
    required int courseId,
    required String title,
    required String description,
    required DateTime deadline,
    required int maxScore,
  }) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await _repository.createTask(
        courseId: courseId,
        title: title,
        description: description,
        deadline: deadline,
        maxScore: maxScore,
        criteria: state.criteria.isEmpty ? null : state.criteria,
      );
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: e.toString()));
    }
  }
}
