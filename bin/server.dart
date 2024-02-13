import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import 'dataset.dart';
import 'sql_handler.dart';

final String arduinoIP = "192.186.10.2";
final String arduinoPort = "80";

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/message:<message>', _echoHandler)
  ..get('/getTemperatureFromSensor', _echoHandler)
  ..get('/getDatasetbyDate', _getDatasetbyDate)
  ..get(
      '/updateDeviceState?device:<device>&state:<newstate>', _updateDeviceState)
  ..get('/turnPumpOn?duration:<duration>', _getDatasetbyDate);
//..get('/setFanState/<newState>', _setFanState);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _getDatasetbyDate(Request req) {
  List<Dataset> datasets =
      Dataset.getDatasetFromDatabaseByDate(DateTime.now(), DateTime.now());

  try {
    String json = "[";
    datasets.forEach((element) {
      //print(element.toJson().toString());
      json += element.toJson().toString();
    });
    json += "]";

    //String json = jsonEncode(datasets as Map<String, dynamic>);
    return Response.ok(json);
  } catch (e) {
    return Response.badRequest(body: "500: ERROR in JSON ENCODIG");
  }
}

Future<Response> _getTemperatureFromSensor(Request request) async {
  try {
    var result = await http.get(
      Uri.http(
        "$arduinoIP:$arduinoPort",
        "/getTemperatureFromSensor",
      ),
    );

    return Response.ok(result.body);
  } catch (e) {
    return Response.badRequest(body: 'ERROR 500: Could not get Data');
  }
}

Future<Response> _updateDeviceState(Request request) async {
  final newState = request.params['newstate'];
  final device = request.params['device'];

  try {
    bool newStateBool = true;

    // String to Bool w. Error Handling
    if (newState!.toLowerCase() == 'false') {
      newStateBool = false;
    } else if (newState.toLowerCase() == 'true') {
      newStateBool = true;
    } else {
      return Response.badRequest(body: 'ERROR 500: No valid input detected');
    }

    // TODO: SEND ACTION TO ARDUINO
    var result = await http.get(
      Uri.http(
        "$arduinoIP:$arduinoPort",
        "/ChangeDeviceState",
        {
          "newstate": newState,
          "device": device,
        },
      ),
    );

    if (result.statusCode != 200) {}

    return Response.ok('200: $device updated to $newState');
  } catch (e) {
    return Response.badRequest(
        body: 'ERROR 500: Could not change State of $device');
  }
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  print('Loading Webserver settings...');

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  final constIP = InternetAddress(
    '192.198.1.10',
    type: InternetAddressType.IPv4,
  );

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server;

  print('Connecting to SQL Server...');
  if (await SQLHandler.connectToSQLServer(SQLHandler.settings)) {
    print('INFO: SQL Server connection established');

    server = await serve(handler, ip, port);
    print('INFO: Server listening on ${ip.address}:$port');
  } else {
    print('ERROR: Could not load SQL Server\nINFO: Shutting down Webserver!');
  }
}
