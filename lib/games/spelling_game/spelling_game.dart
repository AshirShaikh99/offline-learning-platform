import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flame/experimental.dart';
import 'dart:math' as math;

class SpellingGame extends FlameGame
    with TapCallbacks, DragCallbacks, HasCollisionDetection {
  final math.Random random = math.Random();
  late final World gameWorld;
  late final CameraComponent camera;
  final List<Map<String, String>> wordList;
  late final RouterComponent router;
  int currentWordIndex = 0;
  bool isGameOver = false;
  int score = 0;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  SpellingGame({required this.wordList}) : super() {
    gameWorld = World();
    camera = CameraComponent(world: gameWorld);
    camera.viewfinder.anchor = Anchor.topLeft;

    // Fixed: Create route components properly
    router = RouterComponent(
      routes: {
        'gameplay': Route(() => GameplayScene()),
        'victory': Route(() => VictoryScene()),
      },
      initialRoute: 'gameplay',
    );
  }

  @override
  Future<void> onLoad() async {
    camera.viewport.size = Vector2(800, 600);
    await addAll([camera, gameWorld, router]);
  }

  void checkGameOver() {
    if (currentWordIndex >= wordList.length) {
      isGameOver = true;
      router.pushNamed('victory');
    }
  }
}

class GameplayScene extends Component with HasGameRef<SpellingGame> {
  late final Word currentWord;
  late final List<DraggableLetter> letters;
  late final List<LetterSlot> slots;
  late final TextComponent hintText;
  late final TextComponent scoreText;
  late final RectangleComponent background;
  late final SpriteComponent backgroundSprite;

  @override
  Future<void> onLoad() async {
    final wordData = gameRef.wordList[gameRef.currentWordIndex];
    currentWord = Word(word: wordData['word']!, hint: wordData['hint']!);

    // Enhanced background with gradient
    background = RectangleComponent(
      size: Vector2(gameRef.size.x, gameRef.size.y),
      paint:
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF2A2D3E), const Color(0xFF1F1D2B)],
            ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y)),
    );
    await add(background);

    // Add decorative elements
    for (int i = 0; i < 10; i++) {
      final decoration = CircleComponent(
        radius: 5 + (10 * gameRef.random.nextDouble()),
        position: Vector2(
          gameRef.size.x * gameRef.random.nextDouble(),
          gameRef.size.y * gameRef.random.nextDouble(),
        ),
        paint: Paint()..color = Colors.white.withOpacity(0.1),
      );
      await add(decoration);
    }

    // Game title
    final gameTitle = TextComponent(
      text: 'Word Builder',
      position: Vector2(gameRef.size.x / 2, 30),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.blue, offset: Offset(0, 2), blurRadius: 10),
          ],
        ),
      ),
    );
    await add(gameTitle);

    scoreText = TextComponent(
      text: 'Score: ${gameRef.score}',
      position: Vector2(gameRef.size.x - 50, 50),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
      ),
    );

    // Enhanced hint background
    final hintBackground = RectangleComponent(
      size: Vector2(gameRef.size.x * 0.8, 80),
      position: Vector2(gameRef.size.x * 0.1, 80),
      paint:
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.purple.withOpacity(0.3),
              ],
            ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x * 0.8, 80)),
    );
    await add(hintBackground);

    hintText = TextComponent(
      text: 'Hint: ${currentWord.hint}',
      position: Vector2(gameRef.size.x / 2, 120),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 3),
          ],
        ),
      ),
    );

    final wordLength = currentWord.word.length;
    final slotWidth = 70.0;
    final slotSpacing = 15.0;
    final totalSlotsWidth =
        (slotWidth * wordLength) + (slotSpacing * (wordLength - 1));
    final startX = (gameRef.size.x - totalSlotsWidth) / 2;

    // Enhanced slots background
    final slotsBackground = RectangleComponent(
      size: Vector2(totalSlotsWidth + 60, slotWidth + 60),
      position: Vector2(startX - 30, gameRef.size.y * 0.4 - 30),
      paint:
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.withOpacity(0.2),
                Colors.blue.withOpacity(0.2),
              ],
            ).createShader(
              Rect.fromLTWH(0, 0, totalSlotsWidth + 60, slotWidth + 60),
            ),
    );

    // Add rounded corners to slots background
    final slotsBackgroundBorder = RectangleComponent(
      size: Vector2(totalSlotsWidth + 60, slotWidth + 60),
      position: Vector2(startX - 30, gameRef.size.y * 0.4 - 30),
      paint:
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
    );
    await add(slotsBackground);
    await add(slotsBackgroundBorder);

    slots = List.generate(
      wordLength,
      (index) => LetterSlot(
        position: Vector2(
          startX + (index * (slotWidth + slotSpacing)),
          gameRef.size.y * 0.4,
        ),
        size: Vector2(slotWidth, slotWidth),
      ),
    );

    final shuffledLetters = currentWord.word.split('')..shuffle();
    final letterWidth = 60.0;
    final letterSpacing = 15.0;
    final totalLettersWidth =
        (letterWidth * wordLength) + (letterSpacing * (wordLength - 1));
    final letterStartX = (gameRef.size.x - totalLettersWidth) / 2;

    // Enhanced letters background
    final lettersBackground = RectangleComponent(
      size: Vector2(totalLettersWidth + 60, letterWidth + 60),
      position: Vector2(letterStartX - 30, gameRef.size.y * 0.7 - 30),
      paint:
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.withOpacity(0.2),
                Colors.blue.withOpacity(0.2),
              ],
            ).createShader(
              Rect.fromLTWH(0, 0, totalLettersWidth + 60, letterWidth + 60),
            ),
    );

    // Add rounded corners to letters background
    final lettersBackgroundBorder = RectangleComponent(
      size: Vector2(totalLettersWidth + 60, letterWidth + 60),
      position: Vector2(letterStartX - 30, gameRef.size.y * 0.7 - 30),
      paint:
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
    );
    await add(lettersBackground);
    await add(lettersBackgroundBorder);

    letters = List.generate(
      shuffledLetters.length,
      (index) => DraggableLetter(
        letter: shuffledLetters[index],
        position: Vector2(
          letterStartX + (index * (letterWidth + letterSpacing)),
          gameRef.size.y * 0.7,
        ),
        size: Vector2(letterWidth, letterWidth),
        gameScene: this,
      ),
    );

    await addAll([hintText, scoreText, ...slots, ...letters]);
  }

  void checkWord() {
    final String attempt =
        slots.map((slot) => slot.letter?.letter ?? '').join();

    if (attempt == currentWord.word) {
      onCorrectWord();
    } else if (!slots.any((slot) => slot.letter == null)) {
      onIncorrectWord();
    }
  }

  void onCorrectWord() {
    gameRef.score += 100;

    // Enhanced particle effects for correct word
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 100,
        lifespan: 2,
        generator:
            (i) => AcceleratedParticle(
              acceleration: Vector2(0, 50),
              position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.4),
              speed: Vector2(
                gameRef.random.nextDouble() * 200 - 100,
                gameRef.random.nextDouble() * -200,
              ),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint =
                      Paint()
                        ..color =
                            HSLColor.fromAHSL(
                              particle.progress * 0.5,
                              (360 * particle.progress) % 360,
                              0.8,
                              0.5 + 0.2 * particle.progress,
                            ).toColor();
                  canvas.drawCircle(
                    Offset.zero,
                    3 + 3 * (1 - particle.progress),
                    paint,
                  );
                },
              ),
            ),
      ),
    );
    add(particleComponent);

    // Success sound effect placeholder
    // final audio = AudioPool('success.wav');
    // audio.start();

    // Add a success message
    final successMessage = TextComponent(
      text: 'Correct!',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Colors.green,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
    );

    add(successMessage);

    successMessage.add(
      SequenceEffect([
        ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.3)),
        ScaleEffect.by(Vector2.all(1 / 1.5), EffectController(duration: 0.3)),
        RemoveEffect(),
      ]),
    );

    // Move to next word with a slight delay for feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      gameRef.currentWordIndex++;
      gameRef.checkGameOver();
      if (!gameRef.isGameOver) {
        removeAll(children);
        onLoad();
      }
    });
  }

  void onIncorrectWord() {
    // Shake all slots for incorrect answer
    for (final slot in slots) {
      slot.shake();
    }

    // Add a failure message
    final failureMessage = TextComponent(
      text: 'Try Again!',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.red,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );

    add(failureMessage);

    failureMessage.add(
      SequenceEffect([
        MoveByEffect(
          Vector2(0, -20),
          EffectController(duration: 0.5, curve: Curves.elasticOut),
        ),
        RemoveEffect(),
      ]),
    );
  }
}

class RestartButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;

  RestartButton({
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size);

  @override
  bool onTapDown(TapDownEvent event) {
    onTap();
    return true;
  }

  @override
  void render(Canvas canvas) {
    // Enhanced button with gradient and shadow
    final shadowPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(5, 5, size.x, size.y),
            const Radius.circular(12),
          ),
        );
    canvas.drawPath(shadowPath, Paint()..color = Colors.black.withOpacity(0.5));

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue[600]!, Colors.blue[800]!],
    );

    canvas.drawRRect(
      rect,
      Paint()..shader = gradient.createShader(rect.outerRect),
    );

    // Add inner border
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 2,
    );

    // Add text
    final textSpan = TextSpan(
      text: 'Play Again',
      style: TextStyle(
        color: Colors.white,
        fontSize: size.y * 0.4,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final xCenter = (size.x - textPainter.width) / 2;
    final yCenter = (size.y - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }
}

class VictoryScene extends Component with HasGameRef<SpellingGame> {
  @override
  Future<void> onLoad() async {
    // Enhanced victory background
    final background = RectangleComponent(
      size: Vector2(gameRef.size.x, gameRef.size.y),
      paint:
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF2A2D3E), const Color(0xFF1F1D2B)],
            ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y)),
    );

    await add(background);

    // Add celebration particles
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 100,
        lifespan: 5,
        generator:
            (i) => AcceleratedParticle(
              acceleration: Vector2(0, 20),
              position: Vector2(
                gameRef.random.nextDouble() * gameRef.size.x,
                -20,
              ),
              speed: Vector2(0, gameRef.random.nextDouble() * 20 + 30),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint =
                      Paint()
                        ..color =
                            HSLColor.fromAHSL(
                              particle.progress * 0.5 + 0.5,
                              (360 * particle.progress + i * 20) % 360,
                              0.8,
                              0.6,
                            ).toColor();
                  canvas.drawCircle(
                    Offset.zero,
                    5 * (1 - particle.progress) + 2,
                    paint,
                  );
                },
              ),
            ),
      ),
    );
    await add(particleComponent);

    // Victory title
    final victoryTitle = TextComponent(
      text: 'Victory!',
      position: Vector2(gameRef.size.x / 2, 150),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 72,
          color: Colors.yellowAccent,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.orange, offset: Offset(3, 3), blurRadius: 10),
          ],
        ),
      ),
    );

    victoryTitle.add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(duration: 1, reverseDuration: 1, infinite: true),
        ),
      ]),
    );

    await add(victoryTitle);

    final scoreText = TextComponent(
      text: 'Final Score: ${gameRef.score}',
      position: Vector2(gameRef.size.x / 2, 250),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.blue, offset: Offset(2, 2), blurRadius: 5),
          ],
        ),
      ),
    );
    await add(scoreText);

    final restartButton = RestartButton(
      position: Vector2(gameRef.size.x / 2 - 100, gameRef.size.y / 2 + 50),
      size: Vector2(200, 60),
      onTap: () {
        gameRef.currentWordIndex = 0;
        gameRef.score = 0;
        gameRef.router.pushNamed('gameplay');
      },
    );
    await add(restartButton);
  }
}

@immutable
class Word {
  final String word;
  final String hint;

  const Word({required this.word, required this.hint});
}

class DraggableLetter extends PositionComponent with DragCallbacks {
  final String letter;
  final GameplayScene gameScene;
  LetterSlot? _currentSlot;
  Vector2? _dragDeltaPosition;
  Vector2 originalPosition;
  bool isDragging = false;

  DraggableLetter({
    required this.letter,
    required Vector2 position,
    required Vector2 size,
    required this.gameScene,
  }) : originalPosition = position.clone(),
       super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Enhanced letter tile with 3D effect
    final shadowPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3, 3, size.x, size.y),
            const Radius.circular(12),
          ),
        );
    canvas.drawPath(shadowPath, Paint()..color = Colors.black.withOpacity(0.3));

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );

    // Enhanced gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDragging ? Colors.blue[300]! : Colors.blue[700]!,
        isDragging ? Colors.blue[600]! : Colors.blue[900]!,
      ],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(rect.outerRect)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, paint);

    // Add inner glow/highlight
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
      const Radius.circular(10),
    );

    canvas.drawRRect(
      highlightRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 2,
    );

    final textSpan = TextSpan(
      text: letter,
      style: TextStyle(
        color: Colors.white,
        fontSize: size.x * 0.6,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final xCenter = (size.x - textPainter.width) / 2;
    final yCenter = (size.y - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool onDragStart(DragStartEvent event) {
    isDragging = true;
    _dragDeltaPosition = event.canvasPosition - position;

    // If letter was in a slot, remove it
    if (_currentSlot != null) {
      _currentSlot!.letter = null;
      _currentSlot = null;
    }

    // Add scale effect when dragging
    add(ScaleEffect.by(Vector2.all(1.1), EffectController(duration: 0.2)));

    priority = 100;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    position = event.canvasPosition - _dragDeltaPosition!;

    // Check for slot highlighting
    bool foundSlot = false;
    for (final slot in gameScene.slots) {
      final distance = position.distanceTo(slot.position);
      if (distance < size.x * 0.8 && slot.letter == null) {
        slot.isHighlighted = true;
        foundSlot = true;
      } else {
        slot.isHighlighted = false;
      }
    }

    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    isDragging = false;
    _dragDeltaPosition = null;

    // Remove the scale effect
    add(ScaleEffect.by(Vector2.all(1 / 1.1), EffectController(duration: 0.2)));

    // Check if letter is dropped onto a slot
    bool placed = false;
    for (final slot in gameScene.slots) {
      final distance = position.distanceTo(slot.position);
      slot.isHighlighted = false;

      if (distance < size.x * 0.8 && slot.letter == null) {
        slot.letter = this;
        _currentSlot = slot;
        position = slot.position.clone();
        placed = true;

        // Add a scale effect for feedback
        add(
          SequenceEffect([
            ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.1)),
            ScaleEffect.by(
              Vector2.all(1 / 1.2),
              EffectController(duration: 0.1),
            ),
          ]),
        );

        break;
      }
    }

    // If not placed in a slot, return to original position
    if (!placed) {
      add(
        MoveToEffect(
          originalPosition,
          EffectController(duration: 0.3, curve: Curves.easeOut),
        ),
      );
    }

    // Check if the word is complete
    gameScene.checkWord();

    priority = 0;
    return true;
  }
}

class LetterSlot extends PositionComponent {
  DraggableLetter? letter;
  bool isHighlighted = false;

  LetterSlot({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Enhanced slot with shadow
    final shadowPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3, 3, size.x, size.y),
            const Radius.circular(12),
          ),
        );
    canvas.drawPath(shadowPath, Paint()..color = Colors.black.withOpacity(0.3));

    // Enhanced slot background with gradient
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );

    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isHighlighted
            ? Colors.blue[800]!.withOpacity(0.3)
            : Colors.white.withOpacity(0.05),
        isHighlighted
            ? Colors.blue[600]!.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
      ],
    );

    canvas.drawRRect(
      rect,
      Paint()..shader = bgGradient.createShader(rect.outerRect),
    );

    // Add slot border with shine effect
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(rect.outerRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 3 : 2;

    canvas.drawRRect(rect, paint);
  }

  void shake() {
    add(
      SequenceEffect([
        MoveByEffect(Vector2(-5, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(10, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(-10, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(10, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(-10, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(5, 0), EffectController(duration: 0.05)),
      ]),
    );
  }
}
