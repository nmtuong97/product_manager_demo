import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class MockCategoriesService {
  Future<void> init() async {
    await _copyInitialData('categories.json');
  }

  Future<void> _copyInitialData(String fileName) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$fileName';
    final file = File(dbPath);

    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/mock_data/$fileName');
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await file.writeAsBytes(bytes, flush: true);
    }
  }

  Future<List<dynamic>> readData(String fileName) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$fileName';
    final file = File(dbPath);

    if (await file.exists()) {
      final data = await file.readAsString();
      return json.decode(data) as List<dynamic>;
    }
    return [];
  }

  Future<void> writeData(String fileName, List<dynamic> data) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = '${dbDir.path}/$fileName';
    final file = File(dbPath);
    await file.writeAsString(json.encode(data));
  }
}
