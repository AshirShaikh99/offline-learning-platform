import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/match_connection.dart';
import '../../../domain/entities/matching_game.dart';
import '../../../domain/entities/matching_item.dart';

/// Base class for all matching game states
abstract class MatchingGameState extends Equatable {
  const MatchingGameState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the matching game
class MatchingGameInitial extends MatchingGameState {}

/// State when the matching game is loading
class MatchingGameLoading extends MatchingGameState {}

/// State when the matching game is ready to play
class MatchingGameReady extends MatchingGameState {
  final MatchingGame game;
  final List<MatchingItem> leftItems;
  final List<MatchingItem> rightItems;
  final List<MatchConnection> connections;
  final bool isDragging;
  final String? activeItemId;
  final Offset? dragStart;
  final Offset? dragEnd;
  final bool allMatched;

  const MatchingGameReady({
    required this.game,
    required this.leftItems,
    required this.rightItems,
    this.connections = const [],
    this.isDragging = false,
    this.activeItemId,
    this.dragStart,
    this.dragEnd,
    this.allMatched = false,
  });

  @override
  List<Object?> get props => [
        game,
        leftItems,
        rightItems,
        connections,
        isDragging,
        activeItemId,
        dragStart,
        dragEnd,
        allMatched,
      ];

  MatchingGameReady copyWith({
    MatchingGame? game,
    List<MatchingItem>? leftItems,
    List<MatchingItem>? rightItems,
    List<MatchConnection>? connections,
    bool? isDragging,
    String? activeItemId,
    Offset? dragStart,
    Offset? dragEnd,
    bool? allMatched,
  }) {
    return MatchingGameReady(
      game: game ?? this.game,
      leftItems: leftItems ?? this.leftItems,
      rightItems: rightItems ?? this.rightItems,
      connections: connections ?? this.connections,
      isDragging: isDragging ?? this.isDragging,
      activeItemId: activeItemId ?? this.activeItemId,
      dragStart: dragStart ?? this.dragStart,
      dragEnd: dragEnd ?? this.dragEnd,
      allMatched: allMatched ?? this.allMatched,
    );
  }

  /// Get a connection by source and target IDs
  MatchConnection? getConnection(String sourceId, String targetId) {
    return connections.firstWhere(
      (connection) =>
          connection.sourceId == sourceId && connection.targetId == targetId,
      orElse: () => MatchConnection(
        sourceId: '',
        targetId: '',
        isCorrect: false,
        startPoint: Offset.zero,
        endPoint: Offset.zero,
      ),
    );
  }

  /// Check if an item is connected
  bool isItemConnected(String itemId) {
    return connections.any(
      (connection) =>
          connection.sourceId == itemId || connection.targetId == itemId,
    );
  }

  /// Get all connections for an item
  List<MatchConnection> getConnectionsForItem(String itemId) {
    return connections.where(
      (connection) =>
          connection.sourceId == itemId || connection.targetId == itemId,
    ).toList();
  }
}

/// State when the matching game is completed
class MatchingGameCompleted extends MatchingGameState {
  final MatchingGame game;
  final int score;
  final int totalPossibleScore;

  const MatchingGameCompleted({
    required this.game,
    required this.score,
    required this.totalPossibleScore,
  });

  @override
  List<Object?> get props => [game, score, totalPossibleScore];
}

/// State when there's an error in the matching game
class MatchingGameError extends MatchingGameState {
  final String message;

  const MatchingGameError(this.message);

  @override
  List<Object?> get props => [message];
}
