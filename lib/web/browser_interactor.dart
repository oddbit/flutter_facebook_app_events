import 'dart:async';
import 'dart:js';

class BrowserInteractor {
  dynamic callJSMethod(
      List<String> jsVariablePath, String jsFunctionName, List args) {
    var jsArgs = [];
    jsArgs.addAll(args);

    // JS context from window browser
    var object = context;
    for (String entry in jsVariablePath) {
      print(object[entry]);
      object = object[entry];
    }
    return object.callMethod(jsFunctionName, jsArgs);
  }
}
