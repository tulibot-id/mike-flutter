part of provider;

class LoginService with ChangeNotifier {
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  bool _check = false;
  String _email = '', _password = '';
  bool _showPassword = false;

  GlobalKey<FormState> get formKeyLogin => _formKeyLogin;

  String get email => _email;
  String get password => _password;
  bool get check => _check;
  bool get showPassword => _showPassword;

  void setEmail(String text) {
    _email = text;
    notifyListeners();
  }

  void setPassword(String text) {
    _password = text;
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setCheck(bool value) {
    _check = value;
    notifyListeners();
  }

  void discard() {
    _check = false;
    _email = '';
    _password = '';
  }
}

class SignupService with ChangeNotifier {
  final GlobalKey<FormState> _formKeySignup = GlobalKey<FormState>();
  bool _check = false;
  String _name = '';
  String _email = '';
  String _password = '';
  bool _showPassword = false;

  GlobalKey<FormState> get formKeySignup => _formKeySignup;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  bool get check => _check;
  bool get showPassword => _showPassword;

  void setName(String text) {
    _name = text;
    notifyListeners();
  }

  void setEmail(String text) {
    _email = text;
    notifyListeners();
  }

  void setPassword(String text) {
    _password = text;
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setCheck(bool value) {
    _check = value;
    notifyListeners();
  }

  void discard() {
    _check = false;
    _name = '';
    _email = '';
    _password = '';
  }
}

class ResetPasswordService with ChangeNotifier {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _email = '',
      _userId = '',
      _secret = '',
      _newPassword = '',
      _confirmNewPassword = '';

  GlobalKey<FormState> get key => _key;
  String get email => _email;
  String get userId => _userId;
  String get secret => _secret;
  String get newPassword => _newPassword;
  String get confirmNewPassword => _confirmNewPassword;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setToken(String userId, String secret) {
    _userId = userId;
    _secret = secret;
    notifyListeners();
  }

  void setNewPassword(String password) {
    _newPassword = password;
    notifyListeners();
  }

  void setConfirmNewPassword(String password) {
    _confirmNewPassword = password;
    notifyListeners();
  }

  void discard() {
    _key = GlobalKey<FormState>();
    _email = '';
    _userId = '';
    _secret = '';
    _newPassword = '';
    _confirmNewPassword = '';
  }
}
