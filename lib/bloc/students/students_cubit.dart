import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/student_repo.dart';
import '../../data/model/student_model.dart';
import 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  final StudentRepo _studentRepo;
  List<StudentModel> _allStudents = [];

  StudentsCubit(this._studentRepo) : super(StudentsInitial());

  Future<void> getStudents({int? sectionId}) async {
    if (isClosed) return;
    
    emit(StudentsLoading());
    
    try {
      final students = await _studentRepo.getStudents(sectionId: sectionId);
      if (isClosed) return;
      emit(StudentsLoaded(students));
    } catch (e) {
      if (isClosed) return;
      emit(StudentsError(e.toString()));
    }
  }

  Future<void> getAllStudents() async {
    if (isClosed) return;
    
    emit(StudentsLoading());
    
    try {
      final students = await _studentRepo.getAllStudents();
      if (isClosed) return;
      emit(StudentsLoaded(students));
    } catch (e) {
      if (isClosed) return;
      emit(StudentsError(e.toString()));
    }
  }

  Future<void> refreshStudents({int? sectionId}) async {
    if (isClosed) return;
    if (sectionId != null) {
      await getStudents(sectionId: sectionId);
    } else {
      await getAllStudents();
    }
  }

  List<StudentModel> get students => _allStudents;

  List<StudentModel> getStudentsBySection(int sectionId) {
    return _allStudents
        .where((student) => student.sectionId == sectionId)
        .toList();
  }
}
