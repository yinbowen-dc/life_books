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
      title: 'AI Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1D1D1F)), // 深空灰
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFF000000), // 纯黑背景
      ),
      home: const MyHomePage(title: 'AI Assistant'),
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
  late AnimationController _pulseController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _waveController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _waveController.stop();
        _pulseController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: GestureDetector(
        onTap: _toggleListening,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF000000),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 状态栏区域
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFF38383A),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _isListening ? '正在聆听...' : 'AI Assistant',
                      style: TextStyle(
                        color: Color(0xFFF2F2F7),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              // 中心可视化区域
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _waveController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WaveformPainter(
                          _waveController.value,
                          _pulseController.value,
                          _isListening,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 底部控制区域
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // 主按钮
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isListening
                            ? LinearGradient(
                                colors: [
                                  Color(0xFF007AFF),
                                  Color(0xFF0051D5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _isListening ? null : Color(0xFF1C1C1E),
                        border: Border.all(
                          color: _isListening ? Colors.transparent : Color(0xFF38383A),
                          width: 1,
                        ),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: Color(0xFF007AFF).withOpacity(0.3),
                                  blurRadius: 24,
                                  spreadRadius: 0,
                                  offset: Offset(0, 8),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic_none,
                        color: _isListening ? Colors.white : Color(0xFF8E8E93),
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 16),
                    // 提示文字
                    Text(
                      _isListening ? '轻触停止' : '轻触开始',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 移除了Particle和ParticlePainter类，采用更简洁的设计

class WaveformPainter extends CustomPainter {
  final double waveValue;
  final double pulseValue;
  final bool isActive;

  WaveformPainter(this.waveValue, this.pulseValue, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    if (isActive) {
      // 活跃状态：动态波形
      _drawActiveWaveform(canvas, center, size);
    } else {
      // 静止状态：简洁的同心圆
      _drawIdleState(canvas, center);
    }
  }

  void _drawActiveWaveform(Canvas canvas, Offset center, Size size) {
    // 外层光晕
    final glowPaint = Paint()
      ..color = Color(0xFF007AFF).withOpacity(0.1)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 30);
    canvas.drawCircle(center, 80 + pulseValue * 20, glowPaint);
    
    // 动态波形环
    for (int i = 0; i < 3; i++) {
      final baseRadius = 40.0 + i * 20;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color(0xFF007AFF).withOpacity(0.6 - i * 0.15);
      
      final path = Path();
      bool firstPoint = true;
      
      for (double angle = 0; angle <= 2 * math.pi; angle += 0.05) {
        final waveAmplitude = (3 - i) * 2;
        final frequency = 4 + i;
        final waveOffset = math.sin(angle * frequency + waveValue * 4 * math.pi) * 
                          waveAmplitude * (1 + pulseValue * 0.5);
        
        final radius = baseRadius + waveOffset + pulseValue * 8;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    
    // 中心核心
    final corePaint = Paint()
      ..color = Color(0xFF007AFF)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(center, 6 + pulseValue * 3, corePaint);
    
    final innerCorePaint = Paint()
      ..color = Colors.white;
    canvas.drawCircle(center, 3 + pulseValue * 1.5, innerCorePaint);
  }

  void _drawIdleState(Canvas canvas, Offset center) {
    // 静态同心圆
    for (int i = 0; i < 3; i++) {
      final radius = 30.0 + i * 15;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Color(0xFF38383A).withOpacity(0.8 - i * 0.2);
      
      canvas.drawCircle(center, radius, paint);
    }
    
    // 中心点
    final centerPaint = Paint()
      ..color = Color(0xFF8E8E93);
    canvas.drawCircle(center, 4, centerPaint);
    
    final innerPaint = Paint()
      ..color = Color(0xFF1C1C1E);
    canvas.drawCircle(center, 2, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
