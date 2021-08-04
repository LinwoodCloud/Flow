import 'package:meta/meta.dart';

import 'json_object.dart';

@immutable
class Assigned extends JsonObject {
  final bool? everyone;
  final List<AssignedObject> teams;
  final List<AssignedObject> users;
  final List<AssignedObject> seasons;

  const Assigned(
      {this.teams = const [],
      this.users = const [],
      this.seasons = const [],
      this.everyone});

  Assigned.fromJson(Map<String, dynamic> json)
      : teams = List.from(json['teams'] ?? [])
            .map((e) => AssignedObject.fromJson(e))
            .toList(),
        users = List.from(json['users'] ?? [])
            .map((e) => AssignedObject.fromJson(e))
            .toList(),
        seasons = List.from(json['seasons'] ?? [])
            .map((e) => AssignedObject.fromJson(e))
            .toList(),
        everyone = json['everyone'];

  @override
  Map<String, dynamic> toJson() => {
        'teams': teams.map((e) => e.toJson()).toList(),
        'users': users.map((e) => e.toJson()).toList(),
        'seasons': seasons.map((e) => e.toJson()).toList(),
        'everyone': everyone
      };

  @override
  Assigned copyWith(
          {bool? everyone,
          bool removeEveryone = false,
          List<AssignedObject>? teams,
          List<AssignedObject>? users,
          List<AssignedObject>? seasons}) =>
      Assigned(
          teams: teams ?? this.teams,
          seasons: seasons ?? this.seasons,
          everyone: removeEveryone ? true : (everyone ?? this.everyone),
          users: users ?? this.users);

  @override
  List<Object?> get props => [everyone, teams, users, seasons];
}

@immutable
class AssignedObject extends JsonObject {
  final int? id;
  final bool? flag;

  const AssignedObject({this.id, required this.flag});

  AssignedObject.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        flag = json['flag'];

  @override
  AssignedObject copyWith({int? id, bool? flag, bool removeFlag = false}) =>
      AssignedObject(
          flag: removeFlag ? null : (flag ?? this.flag), id: id ?? this.id);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'flag': flag};

  @override
  List<Object?> get props => [id];
}
