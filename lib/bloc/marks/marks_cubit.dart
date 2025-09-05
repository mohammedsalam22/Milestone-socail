import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/mark_repo.dart';
import '../../data/model/mark_model.dart';
import 'marks_state.dart';

class MarksCubit extends Cubit<MarksState> {
  final MarkRepo _markRepo;
  List<MarkModel> _allMarks = [];

  MarksCubit(this._markRepo) : super(MarksInitial());

  Future<void> getStudentMarks({required int studentId}) async {
    if (isClosed) return;

    emit(MarksLoading());

    try {
      final marks = await _markRepo.getStudentMarks(studentId: studentId);
      if (isClosed) return;
      _allMarks = marks;
      emit(MarksLoaded(marks));
    } catch (e) {
      if (isClosed) return;
      emit(MarksError(e.toString()));
    }
  }

  Future<void> refreshMarks({required int studentId}) async {
    if (isClosed) return;
    await getStudentMarks(studentId: studentId);
  }

  List<MarkModel> get marks => _allMarks;
}
