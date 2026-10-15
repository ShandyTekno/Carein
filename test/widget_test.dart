import 'package:flutter_test/flutter_test.dart';

import 'package:carein/models/dummy_models.dart';

void main() {
  test('dummy data is available for the prototype', () {
    expect(DummyData.latest.score, 78);
    expect(DummyData.history.length, 3);
    expect(DummyData.morning.length, 3);
    expect(DummyData.night.length, 3);
  });
}
