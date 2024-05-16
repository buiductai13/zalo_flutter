import 'package:hive_flutter/hive_flutter.dart';

class BlockMessDataBase {
  List data = [];

  final _myBox = Hive.box('mybox');

  void createInitialData(String userId, String blockId) {
    data = [
      [userId, blockId, false],
    ];
  }

  // load the data from database
  void loadData() {
    data = _myBox.get("BLOCK");
  }

  // update the database
  void updateDataBase() {
    _myBox.put("BLOCK", data);
  }
}
