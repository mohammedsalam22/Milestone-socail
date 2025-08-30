import '../../data/model/incident_model.dart';

abstract class IncidentsState {}

class IncidentsInitial extends IncidentsState {}

class IncidentsLoading extends IncidentsState {}

class IncidentsLoaded extends IncidentsState {
  final List<IncidentModel> incidents;

  IncidentsLoaded(this.incidents);
}

class IncidentCreated extends IncidentsState {
  final IncidentModel incident;

  IncidentCreated(this.incident);
}

class IncidentDeleted extends IncidentsState {
  final int incidentId;

  IncidentDeleted(this.incidentId);
}

class IncidentsError extends IncidentsState {
  final String message;

  IncidentsError(this.message);
}
