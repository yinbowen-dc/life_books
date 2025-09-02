import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
// 程序的入口
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF002FA7)), // 克莱因蓝的标准色值
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  bool _isListening = false;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(50, (index) {
      return Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        speed: 0.001 + math.Random().nextDouble() * 0.002,
        size: 1 + math.Random().nextDouble() * 3,
        opacity: 0.3 + math.Random().nextDouble() * 0.7,
      );
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景粒子效果
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _particleController.value),
                size: Size.infinite,
              );
            },
          ),
          // 主要内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题
                Text(
                  'AI 语音助手',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 60),
                // 中央动态形状
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _waveController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: WaveformPainter(
                          _waveController.value,
                          _pulseController.value,
                          _isListening,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 80),
                // 控制按钮
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening 
                              ? Colors.red.withOpacity(0.8)
                              : Color(0xFF002FA7).withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? Colors.red : Color(0xFF002FA7))
                                  .withOpacity(0.3 + _pulseController.value * 0.4),
                              blurRadius: 20 + _pulseController.value * 10,
                              spreadRadius: 5 + _pulseController.value * 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _isListening ? '正在聆听...' : '点击开始对话',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });

  void update() {
    y -= speed;
    if (y < 0) {
      y = 1.0;
      x = math.Random().nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();
      paint.color = Colors.white.withOpacity(particle.opacity * 0.6);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaveformPainter extends CustomPainter {
  final double waveValue;
  final double pulseValue;
  final bool isActive;

  WaveformPainter(this.waveValue, this.pulseValue, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制多层波形
    for (int i = 0; i < 5; i++) {
      final radius = 50.0 + i * 25 + (isActive ? pulseValue * 30 : 0);
      final opacity = 0.8 - i * 0.15;
      
      paint.color = Color(0xFF002FA7).withOpacity(opacity);
      
      final path = Path();
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final waveOffset = math.sin(angle * 3 + waveValue * 2 * math.pi) * 
                          (isActive ? 15 + pulseValue * 10 : 5);
        final x = center.dx + (radius + waveOffset) * math.cos(angle);
        final y = center.dy + (radius + waveOffset) * math.sin(angle);
        
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 中心发光点
    if (isActive) {
      final glowPaint = Paint()
        ..color = Color(0xFF002FA7).withOpacity(0.8)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
      
      canvas.drawCircle(center, 8 + pulseValue * 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
