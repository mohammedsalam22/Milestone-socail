import '../api/group_api.dart';
import '../model/group_model.dart';

class GroupRepo {
  final GroupApi _groupApi;

  GroupRepo(this._groupApi);

  Future<List<GroupModel>> getGroups() async {
    try {
      return await _groupApi.getGroups();
    } catch (e) {
      rethrow;
    }
  }

  Future<GroupModel> createGroup(CreateGroupRequest request) async {
    try {
      return await _groupApi.createGroup(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroupModel> updateGroup(
    int groupId,
    CreateGroupRequest request,
  ) async {
    try {
      return await _groupApi.updateGroup(groupId, request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      return await _groupApi.deleteGroup(groupId);
    } catch (e) {
      rethrow;
    }
  }
}
