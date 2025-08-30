import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/incident_repo.dart';
import '../../data/model/incident_model.dart';
import 'incidents_state.dart';

class IncidentsCubit extends Cubit<IncidentsState> {
  final IncidentRepo _incidentRepo;
  List<IncidentModel> _allIncidents = [];

  IncidentsCubit(this._incidentRepo) : super(IncidentsInitial());

  Future<void> getIncidents({int? sectionId}) async {
    if (isClosed) return;
    
    emit(IncidentsLoading());
    
    try {
      final incidents = await _incidentRepo.getIncidents(sectionId: sectionId);
      if (isClosed) return;
      emit(IncidentsLoaded(incidents));
    } catch (e) {
      if (isClosed) return;
      emit(IncidentsError(e.toString()));
    }
  }

  Future<void> createIncident({
    required List<int> studentIds,
    required String title,
    required String procedure,
    required String note,
    required DateTime date,
  }) async {
    if (isClosed) return;
    
    try {
      final incident = await _incidentRepo.createIncident(
        studentIds: studentIds,
        title: title,
        procedure: procedure,
        note: note,
        date: date,
      );
      if (isClosed) return;
      emit(IncidentCreated(incident));
      // Refresh the incidents list
      await getIncidents();
    } catch (e) {
      if (isClosed) return;
      emit(IncidentsError(e.toString()));
    }
  }

  Future<void> deleteIncident(int incidentId) async {
    if (isClosed) return;
    
    try {
      await _incidentRepo.deleteIncident(incidentId);
      if (isClosed) return;
      emit(IncidentDeleted(incidentId));
      // Refresh the incidents list
      await getIncidents();
    } catch (e) {
      if (isClosed) return;
      emit(IncidentsError(e.toString()));
    }
  }

  Future<void> refreshIncidents({int? sectionId}) async {
    if (isClosed) return;
    await getIncidents(sectionId: sectionId);
  }

  List<IncidentModel> get incidents => _allIncidents;
}
