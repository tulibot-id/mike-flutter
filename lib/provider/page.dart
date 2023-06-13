part of provider;

class PageService with ChangeNotifier {
  //* For OnboardingScreen
  bool _isLastPage = false;

  bool get isLastPage => _isLastPage;

  void findLastPage(int index) {
    if (++index == 3) {
      _isLastPage = true;
    } else {
      _isLastPage = false;
    }
    notifyListeners();
  }

  //* For SignScreen
  TogglePage _togglePage = TogglePage.login;

  bool get isLoginPage => _togglePage == TogglePage.login;

  void convertIndexToTogglePage(int index) {
    switch (index) {
      case 0:
        _togglePage = TogglePage.login;
        break;
      case 1:
        _togglePage = TogglePage.signup;
        break;
      default:
        _togglePage = TogglePage.login;
    }
    notifyListeners();
  }

  void discard() {
    _isLastPage = false;
    _togglePage = TogglePage.login;
  }
}
