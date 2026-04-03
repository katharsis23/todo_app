import 'posthog_web_feature_flags_stub.dart'
    if (dart.library.js_util) 'posthog_web_feature_flags_web.dart';

Future<bool> posthogIsFeatureEnabled(String flagKey) {
  return posthogIsFeatureEnabledImpl(flagKey);
}
