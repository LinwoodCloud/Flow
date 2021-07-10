import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared/models/user.dart';

@immutable
class Account extends Equatable {
  final String username;
  final String address;

  Account(this.username, this.address);

  Account.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        address = json['address'] ?? "localhost";

  Account.fromLocalUser(User user)
      : username = user.name,
        address = "localhost";

  Map<String, dynamic> toJson() => {"username": username, "address": address};

  @override
  String toString() {
    return "$username@$address";
  }

  @override
  List<Object?> get props => [toString()];
}
