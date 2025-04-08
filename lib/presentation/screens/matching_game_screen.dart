import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/match_connection.dart';
import '../../domain/entities/matching_game.dart';
import '../blocs/matching_game/matching_game_bloc.dart';
import '../blocs/matching_game/matching_game_event.dart';
import '../blocs/matching_game/matching_game_state.dart';
import '../widgets/animal_card.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/connection_painter.dart';
import '../widgets/word_card.dart';
import 'success_screen.dart';

/// A screen that displays a matching game
class MatchingGameScreen extends StatelessWidget {
  /// The matching game to display
  final MatchingGame game;

  /// Constructor
  const MatchingGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              MatchingGameBloc()..add(InitializeMatchingGameEvent(game)),
      child: const _MatchingGameView(),
    );
  }
}

class _MatchingGameView extends StatelessWidget {
  const _MatchingGameView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchingGameBloc, MatchingGameState>(
      listener: (context, state) {
        if (state is MatchingGameCompleted) {
          // Navigate to success screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => SuccessScreen(
                    game: state.game,
                    score: state.score,
                    totalPossibleScore: state.totalPossibleScore,
                    onPlayAgain: () {
                      Navigator.of(context).pop();
                      context.read<MatchingGameBloc>().add(ResetGameEvent());
                    },
                  ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MatchingGameLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is MatchingGameReady) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.game.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(state.game.colorValue),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<MatchingGameBloc>().add(ResetGameEvent());
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade100, Colors.blue.shade50],
                    ),
                  ),
                ),

                // Game content
                OrientationBuilder(
                  builder: (context, orientation) {
                    return orientation == Orientation.portrait
                        ? _buildPortraitLayout(context, state)
                        : _buildLandscapeLayout(context, state);
                  },
                ),

                // Connection lines
                CustomPaint(
                  painter: ConnectionPainter(
                    connections: state.connections,
                    isDragging: state.isDragging,
                    dragStart: state.dragStart,
                    dragEnd: state.dragEnd,
                  ),
                  size: MediaQuery.of(context).size,
                ),

                // Confetti overlay
                ConfettiOverlay(isActive: state.allMatched),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, MatchingGameReady state) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Drag from an item to its matching name!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(state.game.colorValue),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column (animals)
              Expanded(
                child: ListView.builder(
                  itemCount: state.leftItems.length,
                  itemBuilder: (context, index) {
                    final item = state.leftItems[index];
                    final isConnected = state.isItemConnected(item.id);
                    final connection = state.connections.firstWhere(
                      (connection) =>
                          connection.sourceId == item.id ||
                          connection.targetId == item.id,
                      orElse:
                          () => const MatchConnection(
                            sourceId: '',
                            targetId: '',
                            isCorrect: false,
                            startPoint: Offset.zero,
                            endPoint: Offset.zero,
                          ),
                    );

                    return Center(
                      child: AnimalCard(
                        key: ValueKey('animal_${item.id}'),
                        item: item,
                        isConnected: isConnected,
                        isCorrect: connection.isCorrect,
                        onDragStart: (position) {
                          context.read<MatchingGameBloc>().add(
                            DragStartedEvent(item.id, position),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Right column (names)
              Expanded(
                child: ListView.builder(
                  itemCount: state.rightItems.length,
                  itemBuilder: (context, index) {
                    final item = state.rightItems[index];
                    final isConnected = state.isItemConnected(item.id);
                    final connection = state.connections.firstWhere(
                      (connection) =>
                          connection.sourceId == item.id ||
                          connection.targetId == item.id,
                      orElse:
                          () => const MatchConnection(
                            sourceId: '',
                            targetId: '',
                            isCorrect: false,
                            startPoint: Offset.zero,
                            endPoint: Offset.zero,
                          ),
                    );

                    return Center(
                      child: WordCard(
                        key: ValueKey('word_${item.id}'),
                        item: item,
                        isConnected: isConnected,
                        isCorrect: connection.isCorrect,
                        onDragEnd:
                            state.isDragging && state.activeItemId != null
                                ? (position) {
                                  context.read<MatchingGameBloc>().add(
                                    DragEndedOnItemEvent(item.id, position),
                                  );
                                }
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, MatchingGameReady state) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Drag from an item to its matching name!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(state.game.colorValue),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column (animals)
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.leftItems.length,
                  itemBuilder: (context, index) {
                    final item = state.leftItems[index];
                    final isConnected = state.isItemConnected(item.id);
                    final connection = state.connections.firstWhere(
                      (connection) =>
                          connection.sourceId == item.id ||
                          connection.targetId == item.id,
                      orElse:
                          () => const MatchConnection(
                            sourceId: '',
                            targetId: '',
                            isCorrect: false,
                            startPoint: Offset.zero,
                            endPoint: Offset.zero,
                          ),
                    );

                    return Center(
                      child: AnimalCard(
                        key: ValueKey('animal_${item.id}'),
                        item: item,
                        isConnected: isConnected,
                        isCorrect: connection.isCorrect,
                        onDragStart: (position) {
                          context.read<MatchingGameBloc>().add(
                            DragStartedEvent(item.id, position),
                          );
                        },
                        // No need for onDragEnd here as we're using Draggable
                      ),
                    );
                  },
                ),
              ),

              // Right column (names)
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.rightItems.length,
                  itemBuilder: (context, index) {
                    final item = state.rightItems[index];
                    final isConnected = state.isItemConnected(item.id);
                    final connection = state.connections.firstWhere(
                      (connection) =>
                          connection.sourceId == item.id ||
                          connection.targetId == item.id,
                      orElse:
                          () => const MatchConnection(
                            sourceId: '',
                            targetId: '',
                            isCorrect: false,
                            startPoint: Offset.zero,
                            endPoint: Offset.zero,
                          ),
                    );

                    return Center(
                      child: WordCard(
                        key: ValueKey('word_${item.id}'),
                        item: item,
                        isConnected: isConnected,
                        isCorrect: connection.isCorrect,
                        onDragEnd: (position) {
                          // This will be called when a draggable is dropped on this target
                          context.read<MatchingGameBloc>().add(
                            DragEndedOnItemEvent(item.id, position),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
