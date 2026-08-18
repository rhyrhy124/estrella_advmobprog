import 'package:flutter_dotenv/flutter_dotenv.dart';

// This gets the API host from the .env file.
final String host =
    dotenv.env['HOST'] ?? '';