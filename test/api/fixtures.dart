import 'dart:convert';
import 'dart:io';

/// Real (sanitized) responses captured from the API on 2026-11-16.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

String fixtureText(String name) =>
    File('test/fixtures/$name.json').readAsStringSync();

Map<String, dynamic> fixtureData(String name) =>
    fixture(name)['data'] as Map<String, dynamic>;
