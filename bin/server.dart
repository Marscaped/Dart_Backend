import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'dataset.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/getDatasetbyDate', _getDatasetbyDate)
  ..get('/setFanState/<newState>', _setFanState);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _getDatasetbyDate(Request req) {
  List<Dataset> datasets =
      Dataset.getDatasetFromDatabaseByDate(DateTime.now(), DateTime.now());

  try {
    String json = "";

    datasets.forEach((element) {
      json += jsonEncode(element.toJson());
    });

    //String json = jsonEncode(datasets as Map<String, dynamic>);
    return Response.ok(json);
  } catch (e) {
    return Response.badRequest(body: "500: ERROR in JSON ENCODIG");
  }
}

Response _setFanState(Request request) {
  final newState = request.params['newState'];

  try {
    bool newStateBool = true;

    // String to Bool w. Error Handling
    if (newState!.toLowerCase() == 'false') {
      newStateBool = false;
    } else if (newState.toLowerCase() == 'true') {
      newStateBool = true;
    } else {
      Response.badRequest(body: 'ERROR 500: No functioning input detected');
    }

    return Response.ok('200: ${newStateBool.toString()}');
  } catch (e) {
    return Response.badRequest(body: 'ERROR 500: Could not change Fan State');
  }
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on ${ip.address}:${port}');
}
