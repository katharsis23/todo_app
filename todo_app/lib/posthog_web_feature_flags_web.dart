import 'dart:js_util' as js_util;

Future<bool> posthogIsFeatureEnabledImpl(String flagKey) async {
  final posthog = js_util.getProperty(js_util.globalThis, 'posthog');
  if (posthog == null) return false;

  final result = js_util.callMethod(posthog, 'isFeatureEnabled', [flagKey]);
  return result == true;
}
