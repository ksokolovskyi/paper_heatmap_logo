import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HeatmapShaderController {
  HeatmapShaderController.withDefaults({
    required TickerProvider vsync,
  }) : angle = HeatmapShaderEditableParameter(
         minValue: 0,
         maxValue: 360,
         defaultValue: 0,
       ),
       noise = HeatmapShaderEditableParameter(
         minValue: 0,
         maxValue: 1,
         defaultValue: 0,
       ),
       innerGlow = HeatmapShaderEditableParameter(
         minValue: 0,
         maxValue: 1,
         defaultValue: 0.5,
       ),
       outerGlow = HeatmapShaderEditableParameter(
         minValue: 0,
         maxValue: 0.5,
         defaultValue: 0.3,
       ),
       contour = HeatmapShaderEditableParameter(
         minValue: 0,
         maxValue: 1,
         defaultValue: 0.5,
       ),
       time = HeatmapShaderParameter(
         minValue: 0,
         maxValue: double.infinity,
         defaultValue: 0,
       ) {
    speed = HeatmapShaderEditableParameter(
      minValue: 0,
      maxValue: 1,
      defaultValue: 0.2,
      onValueChanged: _onSpeedChanged,
    );

    _ticker = vsync.createTicker(_onTick);
  }

  final HeatmapShaderEditableParameter angle;

  final HeatmapShaderEditableParameter noise;

  final HeatmapShaderEditableParameter innerGlow;

  final HeatmapShaderEditableParameter outerGlow;

  final HeatmapShaderEditableParameter contour;

  late final HeatmapShaderEditableParameter speed;

  final HeatmapShaderParameter time;

  late final Ticker _ticker;

  var _elapsedMilliseconds = 0;

  List<ValueListenable<double>> get parameters => [
    angle,
    noise,
    innerGlow,
    outerGlow,
    contour,
    speed,
    time,
  ];

  void dispose() {
    angle.dispose();
    noise.dispose();
    innerGlow.dispose();
    outerGlow.dispose();
    contour.dispose();
    speed.dispose();
    time.dispose();

    _ticker.dispose();
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
    _elapsedMilliseconds = 0;
  }

  void _onSpeedChanged(double speed) {
    if (speed == 0) {
      stop();
    } else if (!_ticker.isTicking) {
      start();
    }
  }

  void _onTick(Duration elapsed) {
    final milliseconds = elapsed.inMilliseconds;
    final difference = milliseconds - _elapsedMilliseconds;

    time._value.value += difference * speed.value;

    _elapsedMilliseconds = milliseconds;
  }
}

class HeatmapShaderParameter implements ValueListenable<double> {
  HeatmapShaderParameter({
    required this.minValue,
    required this.maxValue,
    required double defaultValue,
  }) : assert(
         defaultValue >= minValue && defaultValue <= maxValue,
         'value is not in the allowed range',
       ),
       _value = ValueNotifier(defaultValue);

  final double minValue;

  final double maxValue;

  final ValueNotifier<double> _value;

  @override
  double get value => _value.value;

  void dispose() {
    _value.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    _value.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _value.removeListener(listener);
  }
}

class HeatmapShaderEditableParameter extends HeatmapShaderParameter {
  HeatmapShaderEditableParameter({
    required super.minValue,
    required super.maxValue,
    required super.defaultValue,
    ValueChanged<double>? onValueChanged,
  }) : _onValueChanged = onValueChanged;

  final ValueChanged<double>? _onValueChanged;

  set value(double newValue) {
    assert(
      newValue >= minValue && newValue <= maxValue,
      'value is not in the allowed range',
    );

    _value.value = newValue;
    _onValueChanged?.call(newValue);
  }
}
