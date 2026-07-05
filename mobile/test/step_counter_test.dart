import 'package:aimedic/features/tracking/step_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const today = '2026-07-05';

  test('first reading of the day sets baseline, credits zero', () {
    final (steps, next) = applyReading(null, 5230, today);
    expect(steps, 0);
    expect(next.base, 5230);
    expect(next.date, today);
  });

  test('subsequent readings credit the delta', () {
    var stored = const StepBaseline(date: today, base: 5000, last: 5000);
    final (steps, next) = applyReading(stored, 5340, today);
    expect(steps, 340);
    expect(next.base, 5000);
    expect(next.last, 5340);
  });

  test('midnight rollover starts a fresh day', () {
    const stored = StepBaseline(date: '2026-07-04', base: 5000, last: 9800);
    final (steps, next) = applyReading(stored, 9850, today);
    expect(steps, 0); // yesterday's 4800 belong to yesterday
    expect(next.base, 9850);
    expect(next.date, today);
  });

  test('reboot preserves steps already credited today', () {
    const stored = StepBaseline(date: today, base: 5000, last: 7500);
    // Sensor restarted near zero after reboot.
    final (steps, next) = applyReading(stored, 12, today);
    expect(steps, 2500); // the 2500 credited before the reboot survive
    // Walking on adds to the same total.
    final (steps2, _) = applyReading(next, 112, today);
    expect(steps2, 2600);
  });
}
