import 'package:rxdart/subjects.dart';

class PageName {
  static const String arbPage = "arb";
  static const String logPage = "log";
}

class AppBloc {
  BehaviorSubject<String> _switchPageSubject = BehaviorSubject<String>();
  Stream<String> get switchPageStream => _switchPageSubject.stream;
  Sink<String> get switchPageSink => _switchPageSubject.sink;
}
