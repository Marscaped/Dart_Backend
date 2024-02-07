import 'package:mysql1/mysql1.dart';

class SQLHandler {
  static ConnectionSettings settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'bob',
    password: 'wibble',
    db: 'mydb',
  );

  static MySqlConnection? conn;

  static Future<bool> connectToSQLServer(ConnectionSettings SQLSettings) async {
    return true; //DEBUG CODE: DELETE FOR PROD

    try {
      conn = await MySqlConnection.connect(SQLSettings);
      return true;
    } catch (e) {
      return false;
    }
  }
}
