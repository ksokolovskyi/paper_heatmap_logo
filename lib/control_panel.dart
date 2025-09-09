import 'package:flutter/material.dart';
import 'package:paper_heatmap_logo/heatmap_shader_controller.dart';
import 'package:paper_heatmap_logo/simple_slider.dart';
import 'package:provider/provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HeatmapShaderController>();

    final controls = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 12,
        children: [
          _Control(
            label: 'Angle',
            parameter: controller.angle,
          ),
          _Control(
            label: 'Noise',
            parameter: controller.noise,
          ),
          _Control(
            label: 'Inner Glow',
            parameter: controller.innerGlow,
          ),
          _Control(
            label: 'Outer Glow',
            parameter: controller.outerGlow,
          ),
          _Control(
            label: 'Contour',
            parameter: controller.contour,
          ),
          _Control(
            label: 'Speed',
            parameter: controller.speed,
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      child: Builder(
        builder: (context) {
          final windowWidth = MediaQuery.sizeOf(context).width;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: windowWidth >= 1200 ? 500 : double.infinity,
              maxWidth: 500,
            ),
            child: controls,
          );
        },
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.label,
    required this.parameter,
  });

  final String label;

  final HeatmapShaderEditableParameter parameter;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24,
      children: [
        Expanded(
          child: _Label(label: label),
        ),
        RepaintBoundary(
          child: ValueListenableBuilder(
            valueListenable: parameter,
            builder: (context, value, _) {
              final width = MediaQuery.sizeOf(context).width;
              final isCompactLayout = width < 600;

              return Row(
                spacing: 24,
                children: [
                  SizedBox(
                    width: isCompactLayout ? 200 : 160,
                    child: SimpleSlider(
                      value: value,
                      minValue: parameter.minValue,
                      maxValue: parameter.maxValue,
                      onChanged: (value) {
                        parameter.value = value;
                      },
                    ),
                  ),
                  if (!isCompactLayout) _ValuePreview(value: value),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        fontSize: 18,
        height: 28 / 18,
        letterSpacing: -0.68,
        color: Colors.white,
      ),
    );
  }
}

class _ValuePreview extends StatelessWidget {
  const _ValuePreview({
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Color(0x26FFFFFF),
      ),
      child: SizedBox(
        height: 40,
        width: 100,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              value % 1 == 0
                  ? value.toStringAsFixed(0)
                  : value.toStringAsFixed(3),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 24 / 16,
                letterSpacing: -0.68,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
