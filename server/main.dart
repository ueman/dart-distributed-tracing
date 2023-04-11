import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dart_frog/sentry_dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  await Sentry.init((options) {
    options
      ..dsn = 'https://example@sentry.io/add-your-dsn-here'
      ..tracesSampleRate = 1
      ..debug = true
      ..addDartFrogInAppExcludes();
  });
  return await runZonedGuarded(() {
    return serve(handler, ip, port);
  }, (error, stack) {
    final mechanism = Mechanism(type: 'runZonedGuarded', handled: false);
    final throwableMechanism = ThrowableMechanism(mechanism, error);

    final event = SentryEvent(
      throwable: throwableMechanism,
      level: SentryLevel.fatal,
    );

    Sentry.captureEvent(event, stackTrace: stack);
  })!;
}
