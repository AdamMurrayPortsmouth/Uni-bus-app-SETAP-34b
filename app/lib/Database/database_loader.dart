import 'dart:io';

import 'package:app/MapData/bus_time.dart';
import 'package:app/MapData/feature.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

class DatabaseLoader {
  static DatabaseLoader? _databaseLoader;
  final String _relativePath = "database/map_info.db";
  Tuple2<Set<Feature>, Map<String, List<BusTime>>>? _data;

  DatabaseLoader._();

  /// Returns the only instance of DatabaseLoader.
  static DatabaseLoader getDataBaseLoader()
  {
    _databaseLoader ??= DatabaseLoader._();
    return _databaseLoader!;
  }

  /// Loads the database and returns a List of Features. Saves the result to be
  /// given for future calls.
  Future<Tuple2<Set<Feature>, Map<String, List<BusTime>>>> load() async
  {
    _data ??= await _loadDatabase();
    return _data!;
  }

  // Loads the database and returns a List of Features.
   Future<Tuple2<Set<Feature>, Map<String, List<BusTime>>>> _loadDatabase() async
  {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _relativePath);

    // Check if the database exists in getDatabasesPath().
    var exists = await databaseExists(path);

    // If it has not yet been written from the assets folder to the more
    // efficient location to find at getDatabasesPath().
    if (!exists) {
      _writesDatabase(path);
    }

    // Open the database.
    var db = await openDatabase(path, readOnly: true);

    // Gets the Features table.
    List<Map<String, Object?>> featuresList =
      await db.rawQuery('SELECT * FROM Feature');

    List<Map<String, Object?>> busTimesList =
      await db.rawQuery('SELECT * FROM Bus_Times');

    await db.close();

    // Copy's the Feature's table into a set of Features objects.
    Set<Feature> features = {};
    for (Map map in featuresList) {
      features.add(Feature(map["feature_id"], map["feature_name"],
          map["longitude"], map["latitude"]));
    }

    // Copy's the Bus Time's table into a map from bus stop id's to BusTime objects.
    Map<String, List<BusTime>> times = {};
    for (Map map in busTimesList) {
      if (times[map["bus_stop_id"]] == null)
      {
        times[map["bus_stop_id"]] = [];
      }
      times[map["bus_stop_id"]]!.add(BusTime(map["time"]));
    }

    _data = Tuple2(features, times);
    return _data!;
  }

  // This finds the database in the assets folder and copy's it to a location
  // in getDatabasesPath() to be more efficiently found the next time the app
  // loads up.
  _writesDatabase(String path) async
  {
    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets", _relativePath));
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  }
}