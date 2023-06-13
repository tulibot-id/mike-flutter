part of provider;

class SliderService with ChangeNotifier {
  //* for font size
  double _fontSize = 16.0;
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 30.0;

  double get fontSize => _fontSize;
  double get minFontSize => _minFontSize;
  double get maxFontSize => _maxFontSize;

  void changeFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }
}
