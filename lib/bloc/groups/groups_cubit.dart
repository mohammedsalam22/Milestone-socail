import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/group_repo.dart';
import '../../data/model/group_model.dart';
import 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupRepo _groupRepo;
  List<GroupModel> _allGroups = [];

  GroupsCubit(this._groupRepo) : super(GroupsInitial());

  Future<void> getGroups() async {
    if (isClosed) return;

    emit(GroupsLoading());

    try {
      final groups = await _groupRepo.getGroups();
      _allGroups = groups;
      if (isClosed) return;
      emit(GroupsLoaded(groups));
    } catch (e) {
      if (isClosed) return;
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> createGroup(CreateGroupRequest request) async {
    if (isClosed) return;

    emit(GroupCreating());

    try {
      final group = await _groupRepo.createGroup(request);
      _allGroups.add(group);
      if (isClosed) return;
      emit(GroupCreated(group));
      // Refresh the groups list
      await getGroups();
    } catch (e) {
      if (isClosed) return;
      emit(GroupCreateError(e.toString()));
    }
  }

  Future<void> updateGroup(int groupId, CreateGroupRequest request) async {
    if (isClosed) return;

    emit(GroupCreating());

    try {
      final group = await _groupRepo.updateGroup(groupId, request);
      final index = _allGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _allGroups[index] = group;
      }
      if (isClosed) return;
      emit(GroupCreated(group));
      // Refresh the groups list
      await getGroups();
    } catch (e) {
      if (isClosed) return;
      emit(GroupCreateError(e.toString()));
    }
  }

  Future<void> deleteGroup(int groupId) async {
    if (isClosed) return;

    emit(GroupDeleting());

    try {
      await _groupRepo.deleteGroup(groupId);
      _allGroups.removeWhere((group) => group.id == groupId);
      if (isClosed) return;
      emit(GroupDeleted(groupId));
    } catch (e) {
      if (isClosed) return;
      emit(GroupDeleteError(e.toString()));
    }
  }

  Future<void> refreshGroups() async {
    await getGroups();
  }

  List<GroupModel> get groups => _allGroups;

  GroupModel? getGroupById(int id) {
    try {
      return _allGroups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }
}
