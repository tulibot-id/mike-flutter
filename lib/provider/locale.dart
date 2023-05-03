part of provider;

class LocaleService with ChangeNotifier {
  Locale? _locale;

  Locale? get locale =>
      _locale ?? const Locale('en', 'English (United States)');

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) {
      throw Exception('Cant found locale');
    }
    _locale = locale;
    notifyListeners();
  }

  String? _pathFileUploaded;

  String? get pathFileUploaded => _pathFileUploaded;

  void pathFile(String path) {
    _pathFileUploaded = path;
    notifyListeners();
  }

  void discard() {
    _pathFileUploaded = null;
  }
}
