import 'package:posthog_flutter/posthog_flutter.dart';

Future<bool> posthogIsFeatureEnabledImpl(String flagKey) async {
  return await Posthog().isFeatureEnabled(flagKey);
}
