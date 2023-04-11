import 'package:dart_frog/dart_frog.dart';
import 'package:sentry_dart_frog/sentry_dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      // add Sentry middleware
      .use(sentryMiddleware);
}
