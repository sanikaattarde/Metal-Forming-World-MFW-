import 'dart:convert';
import 'dart:io';

/// Reads a JSON fixture under test/fixtures/. Tests run from app/.
Object? readJsonFixture(String relativePath) =>
    jsonDecode(File('test/fixtures/$relativePath').readAsStringSync());
