import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../routes/habits.dart';
import '../routes/logs.dart';
import '../routes/stats.dart';

Response _cors(Response response) {
  return response.change(headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  });
}

Middleware corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        });
      }
      return null;
    },
    responseHandler: (Response response) => _cors(response),
  );
}

void main(List<String> args) async {
  // Use any available host or IPv4 loopback.
  final ip = InternetAddress.anyIPv4;

  initDatabase();

  final habitsRouter = HabitsApi().router;
  final logsRouter = LogsApi().router;
  
  final apiCascade = Cascade()
      .add(habitsRouter.call)
      .add(logsRouter.call);

  final app = Router();
  app.mount('/api/habits', apiCascade.handler);
  app.mount('/api/stats', StatsApi().router.call);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(app.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port \${server.port}');
}
