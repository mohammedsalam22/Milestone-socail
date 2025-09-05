import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/group_model.dart';

class GroupApi {
  final ApiService _apiService;

  GroupApi(this._apiService);

  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _apiService.get(ApiEndpoints.groupRooms);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final groups = data.map((json) => GroupModel.fromJson(json)).toList();
        return groups;
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting groups: $e');
    }
  }

  Future<GroupModel> createGroup(CreateGroupRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.groupRooms,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return GroupModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  Future<GroupModel> updateGroup(
    int groupId,
    CreateGroupRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.groupRooms}/$groupId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return GroupModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating group: $e');
    }
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.groupRooms}/$groupId',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting group: $e');
    }
  }
}
