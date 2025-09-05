import '../../data/model/group_model.dart';

abstract class GroupsState {}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<GroupModel> groups;

  GroupsLoaded(this.groups);
}

class GroupsError extends GroupsState {
  final String message;

  GroupsError(this.message);
}

class GroupCreating extends GroupsState {}

class GroupCreated extends GroupsState {
  final GroupModel group;

  GroupCreated(this.group);
}

class GroupCreateError extends GroupsState {
  final String message;

  GroupCreateError(this.message);
}

class GroupDeleting extends GroupsState {}

class GroupDeleted extends GroupsState {
  final int groupId;

  GroupDeleted(this.groupId);
}

class GroupDeleteError extends GroupsState {
  final String message;

  GroupDeleteError(this.message);
}
