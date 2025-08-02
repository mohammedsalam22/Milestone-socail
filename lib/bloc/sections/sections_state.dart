import '../../data/model/section_model.dart';

abstract class SectionsState {}

class SectionsInitial extends SectionsState {}

class SectionsLoading extends SectionsState {}

class SectionsLoaded extends SectionsState {
  final List<SectionModel> sections;

  SectionsLoaded(this.sections);
}

class SectionsError extends SectionsState {
  final String message;

  SectionsError(this.message);
}
