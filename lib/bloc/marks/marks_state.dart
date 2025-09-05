import '../../data/model/mark_model.dart';

abstract class MarksState {}

class MarksInitial extends MarksState {}

class MarksLoading extends MarksState {}

class MarksLoaded extends MarksState {
  final List<MarkModel> marks;

  MarksLoaded(this.marks);
}

class MarksError extends MarksState {
  final String message;

  MarksError(this.message);
}
