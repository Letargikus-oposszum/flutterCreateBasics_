import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  final double pipeWidth = 0.2;
  final double gapHeight = 0.65;
  double gapY = 0;

  bool passedPipe = false;

  // ================= GAME =================
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;

  Timer? loop;
  final random = Random();

  Size screenSize = Size.zero;

  // =======================================

  double randomGap() => random.nextDouble() * 1.2 - 0.6;

  void startGame() {
    loop?.cancel();
    loop = null;

    setState(() {
      birdY = 0;
      velocity = 0;
      pipeX = 1.5;
      gapY = randomGap();
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
    if (gameOver) return;

    setState(() {
      velocity += gravity;
      birdY -= velocity;

      pipeX -= 0.008;

      if (!passedPipe && pipeX < 0) {
        score++;
        passedPipe = true;
      }

      if (pipeX < -1.5) {
        pipeX = 1.5;
        gapY = randomGap();
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

    final double birdHalfX = birdPx / screenSize.width;
    final double birdHalfY = birdPx / screenSize.height;
    final double pipeHalfX = 50 / screenSize.width;

    // Top / bottom boundary
    if (birdY > 1 - birdHalfY || birdY < -1 + birdHalfY) {
      endGame();
      return;
    }

    final bool withinX =
        pipeX - pipeHalfX < birdHalfX && pipeX + pipeHalfX > -birdHalfX;

    // CHANGED: fixed vertical collision — test bird's actual visual edges
    // against the pipe edges, not the inverted/shrunk version from before.
    // birdY - birdHalfY = top edge of bird
    // birdY + birdHalfY = bottom edge of bird
    // gapY - gapHeight/2 = bottom edge of top pipe
    // gapY + gapHeight/2 = top edge of bottom pipe
    final bool hitTop    = birdY - birdHalfY < gapY - gapHeight / 2;
    final bool hitBottom = birdY + birdHalfY > gapY + gapHeight / 2;

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

    return GestureDetector(
      onTap: () {
        if (!gameStarted || gameOver) {
          startGame();
        } else {
          jump();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            // ===== BIRD =====
            Align(
              alignment: Alignment(0, birdY.clamp(-1.0, 1.0)),
              child: Container(
                width: birdPx,
                height: birdPx,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // ===== TOP PIPE =====
            Align(
              alignment: Alignment(pipeX, -1),
              child: Container(
                width: 50,
                height: screenSize.height *
                    (0.5 - gapHeight / 2 - gapY).clamp(0.0, 1.0),
                color: Colors.green,
              ),
            ),

            // ===== BOTTOM PIPE =====
            Align(
              alignment: Alignment(pipeX, 1),
              child: Container(
                width: 50,
                height: screenSize.height *
                    (0.5 - gapHeight / 2 + gapY).clamp(0.0, 1.0),
                color: Colors.green,
              ),
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

            // ===== START / GAME OVER TEXT =====
            if (!gameStarted)
              Center(
                child: Text(
                  gameOver
                      ? "Game Over!\nScore: $score\n\nTap to Restart"
                      : "Tap to Start",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}