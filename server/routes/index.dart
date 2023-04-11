import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

Future<Response> onRequest(RequestContext context) async {
  final span = Sentry.getSpan()?.startChild('database operation');
  // simulate database access
  await Future<void>.delayed(const Duration(seconds: 1));
  await span?.finish();
  return Response.json(body: {'degrees': 32.0});
}
