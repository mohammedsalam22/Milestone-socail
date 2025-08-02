import '../api/section_api.dart';
import '../model/section_model.dart';

class SectionRepo {
  final SectionApi _sectionApi;

  SectionRepo(this._sectionApi);

  Future<List<SectionModel>> getSections() async {
    try {
      return await _sectionApi.getSections();
    } catch (e) {
      rethrow;
    }
  }
}
