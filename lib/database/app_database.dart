import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/landmark.dart';
import 'landmark_dao.dart';
import 'date_time_converter.dart';

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Landmark])
abstract class AppDatabase extends FloorDatabase {
  LandmarkDao get landmarkDao;
}
