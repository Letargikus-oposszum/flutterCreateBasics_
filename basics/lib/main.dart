import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlappyGame(),
    );
  }
}

class FlappyGame extends StatefulWidget {
  const FlappyGame({super.key});

  @override
  State<FlappyGame> createState() => _FlappyGameState();
}

class _FlappyGameState extends State<FlappyGame> {
  // ================= BIRD =================
  double birdY = 0;
  double velocity = 0;

  final double gravity = -0.0018;
  final double jumpStrength = 0.02;

  static const double birdPx = 35;

  // ================= PIPE =================
  double pipeX = 1.5;
  // CHANGED: pipe width in pixels, used for both rendering and collision
  static const double pipePx = 60;
  // CHANGED: gap is now in pixels for consistency with rendering
  static const double gapPx = 220;
  double gapCenterY = 0; // in pixels from screen center (+ = down)

  bool passedPipe = false;

  // ================= GAME =================
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  bool isPaused = false;
  Timer? loop;
  final random = Random();

  Size screenSize = Size.zero;

  // =======================================

  // CHANGED: randomGap now returns pixels from screen center
  // clamped so pipes never go off screen
  double randomGap() {
    final double maxOffset = screenSize.height / 2 - gapPx / 2 - 60;
    return (random.nextDouble() * 2 - 1) * maxOffset;
  }

  void togglePause() {
    if (!gameStarted || gameOver) return;

    setState(() {
      isPaused = !isPaused;
    });
  }

  void startGame() {
    loop?.cancel();
    loop = null;

    setState(() {
      birdY = 0;
      velocity = 0;
      pipeX = 1.5;
      gapCenterY = screenSize == Size.zero ? 0 : randomGap();
      score = 0;
      passedPipe = false;
      gameStarted = true;
      gameOver = false;
    });

    loop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver || isPaused) return;
    
    setState(() {
      velocity += gravity;
      birdY += velocity;

      pipeX -= 0.008;

      final pipeRightEdge = pipeX + (pipePx / screenSize.width);
      final birdLeftEdge = -(birdPx / 2) / (screenSize.width / 2);

      if (!passedPipe && pipeRightEdge < birdLeftEdge) {
        score++;
        passedPipe = true;
      }
      if (pipeX < -0.5) {
        pipeX = 1.2;
        gapCenterY = randomGap();
        passedPipe = false;
      }

      checkCollision();
    });
  }

  void jump() {
    if (gameStarted && !gameOver) {
      setState(() => velocity = jumpStrength);
    }
  }

  void checkCollision() {
    if (screenSize == Size.zero) return;

    // CHANGED: everything in pixels now — no more mixed unit confusion.
    // Convert bird Alignment Y to pixels from screen center (+ = down).
    final double halfH = screenSize.height / 2;
    final double halfW = screenSize.width / 2;

    // birdY in Alignment: +1 = bottom, -1 = top.
    // birdY in our physics: increases upward (birdY -= velocity).
    // So pixel from center = -birdY * halfH  (flip sign: up in physics = up on screen)
    final double birdPxY = -birdY * halfH; // pixels from center, + = down
    final double birdPxX = 0; // bird is always horizontally centered

    // Pipe center in pixels from screen center
    final double pipePxX = pipeX * halfW;

    // Bird edges in pixels
    final double birdTop = birdPxY - birdPx / 2;
    final double birdBottom = birdPxY + birdPx / 2;
    final double birdLeft = birdPxX - birdPx / 2;
    final double birdRight = birdPxX + birdPx / 2;

    // Pipe edges in pixels
    final double pipeLeft = pipePxX - pipePx / 2;
    final double pipeRight = pipePxX + pipePx / 2;

    // Top/bottom screen boundary
    if (birdBottom > halfH || birdTop < -halfH) {
      endGame();
      return;
    }

    // Horizontal overlap
    final bool withinX = birdRight > pipeLeft && birdLeft < pipeRight;

    // Gap edges in pixels from center
    final double gapTop = gapCenterY - gapPx / 2;
    final double gapBottom = gapCenterY + gapPx / 2;

    // CHANGED: collision checks bird edges against gap edges, all in pixels
    final bool hitTop = birdTop < gapTop;
    final bool hitBottom = birdBottom > gapBottom;

    if (withinX && (hitTop || hitBottom)) {
      endGame();
    }
  }

  void endGame() {
    loop?.cancel();
    loop = null;

    setState(() {
      gameOver = true;
      gameStarted = false;
    });
  }

  // =======================================

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    final double halfH = screenSize.height / 2;
    final double halfW = screenSize.width / 2;

    final double birdPxY = -birdY * halfH;
    final double birdPxX = 0;

    final double birdLeft = halfW + birdPxX - birdPx / 2;
    final double birdTop = halfH + birdPxY - birdPx / 2;

    final double pipePxX = pipeX * halfW;
    final double pipeLeft = halfW + pipePxX - pipePx / 2;

    final double topPipeHeight = (halfH + gapCenterY - gapPx / 2).clamp(
      0,
      screenSize.height,
    );

    final double bottomPipeHeight = (halfH - gapCenterY - gapPx / 2).clamp(
      0,
      screenSize.height,
    );

    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          if (!gameStarted || gameOver) {
            startGame();
          } else {
            jump();
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          if (!gameStarted || gameOver) {
            startGame();
          } else {
            jump();
          }
        },
        child: Scaffold(
          body: Container(
            // 🌤 SKY GRADIENT
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF70C5CE), Color(0xFFB2E0E6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // ===== BIRD =====
                Positioned(
                  left: birdLeft,
                  top: birdTop,
                  child: Container(
                    width: birdPx,
                    height: birdPx,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== TOP PIPE =====
                Positioned(
                  left: pipeLeft,
                  top: 0,
                  child: Container(
                    width: pipePx,
                    height: topPipeHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                // ===== BOTTOM PIPE =====
                Positioned(
                  left: pipeLeft,
                  top: screenSize.height - bottomPipeHeight,
                  child: Container(
                    width: pipePx,
                    height: bottomPipeHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                // ===== GROUND =====
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 40, color: Colors.brown),
                ),

                // ===== SCORE =====
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "$score",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ===== TEXT =====
                if (!gameStarted)
                  Center(
                    child: Text(
                      gameOver
                          ? "Game Over!\nScore: $score\n\nTap to Restart"
                          : "Tap to Start",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
