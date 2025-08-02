import '../../core/servcies/api_service.dart';
import '../model/section_model.dart';

class SectionApi {
  final ApiService _apiService;

  SectionApi(this._apiService);

  Future<List<SectionModel>> getSections() async {
    try {
      final response = await _apiService.get('/api/school/sections');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> sectionsData = response.data;
        return sectionsData
            .map((sectionJson) => SectionModel.fromJson(sectionJson))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch sections. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
