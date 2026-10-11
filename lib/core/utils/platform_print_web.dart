import 'dart:js_interop';

@JS('window.print')
external void _jsPrint();

void triggerPlatformPrint() {
  try {
    _jsPrint();
  } catch (_) {}
}
