part of provider;

class UserService with ChangeNotifier {
  static final UserService instance = UserService._init();
  static SharedPreferences? _preferences;

  UserService._init();

  Future<SharedPreferences> get preferences async {
    if (_preferences != null) return _preferences!;

    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  User? _user = User(
    id: '',
    name: '',
    email: '',
    session: true,
    appLang: 'en',
    fontSize: 14,
  );

  User get user => _user!;
  Future<String> get id async => _user!.id;
  String get name => _user!.name;
  String get email => _user!.email;
  String get appLang => _user!.appLang;

  Future initializedUser() async {
    if (await InternetConnectionChecker().hasConnection) {
      final getUser = await UserAuth.instance.getAccount;
      if (getUser.prefs.data.isEmpty) {
        final json = {
          'appLang': _user!.appLang,
          'fontSize': _user!.fontSize,
        };
        await UserAuth.instance.updatePreferences(json);
      }

      _user = _user!.copy(
        id: getUser.$id,
        name: getUser.name,
        email: getUser.email,
        appLang: getUser.prefs.data['appLang'],
        fontSize: getUser.prefs.data['fontSize'],
      );
      await storeUserAndSettings(_user!);
    } else {
      _user = await loadUserAndSetting();
    }
    notifyListeners();
  }

  Future<bool?> getSession() async {
    if (await InternetConnectionChecker().hasConnection) {
      try {
        final session = await UserAuth.instance.getAccount;
        return session.emailVerification;
      } on aw.AppwriteException catch (_) {
        return null;
      }
    } else {
      _user = await loadUserAndSetting();
      if (_user == null) {
        return null;
      }
      return _user!.session;
    }
  }

  Future storeUserAndSettings(User user) async {
    //Store User Data in Shared Preferences
    final preferences = await instance.preferences;
    final userJson = json.encode(user.toJson());
    preferences.setString('user' + user.id, userJson);
    //Store User Data in Cloud
    await UserAuth.instance.updatePreferences(user.toJsonCloud());
    _user = user;
    notifyListeners();
  }

  Future<User?> loadUserAndSetting() async {
    final preferences = await instance.preferences;
    final usersKey = preferences.getKeys().toList();
    final users = usersKey
        .map((userJson) =>
            User.fromJson(json.decode(preferences.getString(userJson)!)))
        .toList();
    try {
      final user = users.singleWhere((user) => user.session);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future deleteUserAndSetting() async {
    final preferences = await instance.preferences;
    await preferences.remove('user' + _user!.id);
  }

  Future<bool> updateName(String name) async {
    try {
      await UserAuth.instance.updateName(name);
      await storeUserAndSettings(_user!.copy(name: name));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> getProfile() async {
    io.Directory temporaryDirextory = await getTemporaryDirectory();
    final file = io.File('${temporaryDirextory.path}/profile.ext');

    if (await InternetConnectionChecker().hasConnection) {
      final result = await UserAuth.instance.getUserInitialProfile(_user!.name);
      if (result != null) {
        if (file.existsSync()) await file.delete();
        file.writeAsBytesSync(result);
      }
    }
    return file.readAsBytesSync();
  }

  List<Members> members =
      Members.values.skipWhile((value) => value == Members.memberFree).toList();
  Members _selectedMember = Members.memberPro;

  Members get selectedMember => _selectedMember;

  void changeMember(Members member) {
    _selectedMember = member;
    notifyListeners();
  }
}
