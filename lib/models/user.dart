part of models;

class User {
  final String id;
  final String name;
  final String email;
  final bool session;
  final String appLang;
  final int fontSize;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.session,
    required this.appLang,
    required this.fontSize,
  });

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        session: json['session'] as bool,
        appLang: json['appLang'] as String,
        fontSize: json['fontSize'] as int,
      );

  User copy(
          {String? id,
          String? name,
          String? email,
          bool? session,
          String? appLang,
          int? fontSize,
          int? quota,
          int? member}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        session: session ?? this.session,
        appLang: appLang ?? this.appLang,
        fontSize: fontSize ?? this.fontSize,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'session': session,
        'appLang': appLang,
        'fontSize': fontSize,
      };

  Map<String, dynamic> toJsonCloud() => {
        'appLang': appLang,
        'fontSize': fontSize,
      };
}
