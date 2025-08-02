import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/section_repo.dart';
import '../../data/model/section_model.dart';
import 'sections_state.dart';

class SectionsCubit extends Cubit<SectionsState> {
  final SectionRepo _sectionRepo;

  SectionsCubit(this._sectionRepo) : super(SectionsInitial());

  Future<void> getSections() async {
    try {
      emit(SectionsLoading());
      final sections = await _sectionRepo.getSections();
      emit(SectionsLoaded(sections));
    } catch (e) {
      emit(SectionsError(e.toString()));
    }
  }

  void refreshSections() {
    getSections();
  }
}
