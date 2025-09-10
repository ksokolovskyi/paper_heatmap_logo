import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:paper_heatmap_logo/heatmap_logo_state.dart';
import 'package:paper_heatmap_logo/heatmap_shader_controller.dart';
import 'package:provider/provider.dart';

class HeatmapLogo extends StatefulWidget {
  const HeatmapLogo({super.key});

  @override
  State<HeatmapLogo> createState() => _HeatmapLogoState();
}

class _HeatmapLogoState extends State<HeatmapLogo> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: const _Logo(),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HeatmapShaderController>();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 600,
        maxWidth: 600,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: AspectRatio(
                aspectRatio: 1,
                child: ListenableBuilder(
                  listenable: Listenable.merge(controller.parameters),
                  builder: (context, child) {
                    return ShaderBuilder(
                      assetKey: 'assets/shaders/heatmap.frag',
                      (context, shader, _) {
                        return AnimatedSampler(
                          (image, size, canvas) {
                            shader
                              ..setImageSampler(0, image)
                              ..setFloatUniforms((uniforms) {
                                uniforms
                                  // u_size
                                  ..setSize(size)
                                  // u_time
                                  ..setFloat(controller.time.value)
                                  // u_angle
                                  ..setFloat(controller.angle.value)
                                  // u_noise
                                  ..setFloat(controller.noise.value)
                                  // u_innerGlow
                                  ..setFloat(controller.innerGlow.value)
                                  // u_outerGlow
                                  ..setFloat(controller.outerGlow.value)
                                  // u_contour
                                  ..setFloat(controller.contour.value);
                              });

                            canvas.drawRect(
                              Rect.fromLTWH(0, 0, size.width, size.height),
                              Paint()..shader = shader,
                            );
                          },
                          child: child!,
                        );
                      },
                    );
                  },
                  child: const _Image(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Image extends StatefulWidget {
  const _Image();

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 300),
  );

  late final _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  late final HeatmapLogoState _state;

  late HeatmapLogoType _type;

  HeatmapLogoType? _nextType;

  @override
  void initState() {
    super.initState();

    _state = context.read<HeatmapLogoState>();
    _state.addListener(_onTypeChanged);

    _type = _state.type;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _opacity.dispose();

    _state.removeListener(_onTypeChanged);

    super.dispose();
  }

  Future<void> _onTypeChanged() async {
    final nextType = _state.type;

    if (nextType == _type || nextType == _nextType) {
      return;
    }

    _nextType = nextType;

    await _controller.reverse();

    if (!mounted || _nextType != nextType) {
      return;
    }

    setState(() {
      _type = nextType;
      _nextType = null;
    });

    _controller
      ..reset()
      ..forward().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Image.asset(
        _type.asset,
        opacity: _opacity,
      ),
    );
  }
}
