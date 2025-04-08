import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../domain/entities/match_connection.dart';
import '../../../domain/entities/matching_game.dart';
import '../../../domain/entities/matching_item.dart';
import 'matching_game_event.dart';
import 'matching_game_state.dart';

class MatchingGameBloc extends Bloc<MatchingGameEvent, MatchingGameState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  MatchingGameBloc() : super(MatchingGameInitial()) {
    on<InitializeMatchingGameEvent>(_onInitializeGame);
    on<DragStartedEvent>(_onDragStarted);
    on<DragUpdatedEvent>(_onDragUpdated);
    on<DragEndedOnItemEvent>(_onDragEndedOnItem);
    on<DragCanceledEvent>(_onDragCanceled);
    on<ResetGameEvent>(_onResetGame);
    on<CheckAllMatchesEvent>(_onCheckAllMatches);
    on<PlaySoundEvent>(_onPlaySound);
    on<RemoveConnectionEvent>(_onRemoveConnection);
  }

  Future<void> _onInitializeGame(
    InitializeMatchingGameEvent event,
    Emitter<MatchingGameState> emit,
  ) async {
    emit(MatchingGameLoading());

    try {
      final game = event.game;
      final items = game.items;

      // Create shuffled lists for left and right sides
      final leftItems = List<MatchingItem>.from(items);
      final rightItems = List<MatchingItem>.from(items);

      // Shuffle the right items to randomize the matching
      rightItems.shuffle(Random());

      emit(
        MatchingGameReady(
          game: game,
          leftItems: leftItems,
          rightItems: rightItems,
        ),
      );
    } catch (e) {
      emit(MatchingGameError('Failed to initialize game: $e'));
    }
  }

  void _onDragStarted(DragStartedEvent event, Emitter<MatchingGameState> emit) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;

      // Check if the item is already connected
      if (currentState.isItemConnected(event.itemId)) {
        // Remove existing connections for this item
        final connections =
            currentState.connections
                .where((connection) => connection.sourceId != event.itemId)
                .toList();

        emit(
          currentState.copyWith(
            isDragging: true,
            activeItemId: event.itemId,
            dragStart: event.position,
            dragEnd: event.position,
            connections: connections,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            isDragging: true,
            activeItemId: event.itemId,
            dragStart: event.position,
            dragEnd: event.position,
          ),
        );
      }
    }
  }

  void _onDragUpdated(DragUpdatedEvent event, Emitter<MatchingGameState> emit) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      if (currentState.isDragging) {
        emit(currentState.copyWith(dragEnd: event.position));
      }
    }
  }

  void _onDragEndedOnItem(
    DragEndedOnItemEvent event,
    Emitter<MatchingGameState> emit,
  ) async {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      if (currentState.isDragging && currentState.activeItemId != null) {
        final sourceId = currentState.activeItemId!;
        final targetId = event.targetId;

        // Find the source and target items
        final sourceItem = currentState.leftItems.firstWhere(
          (item) => item.id == sourceId,
          orElse:
              () => currentState.rightItems.firstWhere(
                (item) => item.id == sourceId,
                orElse:
                    () => const MatchingItem(id: '', name: '', imagePath: ''),
              ),
        );

        final targetItem = currentState.rightItems.firstWhere(
          (item) => item.id == targetId,
          orElse:
              () => currentState.leftItems.firstWhere(
                (item) => item.id == targetId,
                orElse:
                    () => const MatchingItem(id: '', name: '', imagePath: ''),
              ),
        );

        // Simplified matching logic: just check if the IDs match
        // This works because we've set up the data so that matching items have the same ID
        final isCorrect = sourceItem.id == targetItem.id;

        // Prevent connecting items on the same side (left-to-left or right-to-right)
        final isSourceFromLeft = currentState.leftItems.any(
          (item) => item.id == sourceId,
        );
        final isTargetFromLeft = currentState.leftItems.any(
          (item) => item.id == targetId,
        );

        // If both items are from the same side (both left or both right), don't allow the connection
        if ((isSourceFromLeft && isTargetFromLeft) ||
            (!isSourceFromLeft && !isTargetFromLeft)) {
          // Return early without creating a connection
          emit(currentState.copyWith(isDragging: false, activeItemId: null));
          return;
        }

        // Create a new connection
        final newConnection = MatchConnection(
          sourceId: sourceId,
          targetId: targetId,
          isCorrect: isCorrect,
          startPoint: currentState.dragStart!,
          endPoint: event.position,
        );

        // Add the new connection to the list
        final connections = List<MatchConnection>.from(currentState.connections)
          ..add(newConnection);

        // Play sound based on whether the match is correct
        if (isCorrect) {
          add(const PlaySoundEvent('assets/sounds/correct.mp3'));
        } else {
          add(const PlaySoundEvent('assets/sounds/incorrect.mp3'));
        }

        // Update the state
        emit(
          currentState.copyWith(
            isDragging: false,
            activeItemId: null,
            connections: connections,
          ),
        );

        // Check if all items are matched correctly
        add(CheckAllMatchesEvent());
      } else {
        emit(currentState.copyWith(isDragging: false, activeItemId: null));
      }
    }
  }

  void _onDragCanceled(
    DragCanceledEvent event,
    Emitter<MatchingGameState> emit,
  ) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      emit(currentState.copyWith(isDragging: false, activeItemId: null));
    }
  }

  void _onResetGame(ResetGameEvent event, Emitter<MatchingGameState> emit) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      final game = currentState.game;
      final items = game.items;

      // Create shuffled lists for left and right sides
      final leftItems = List<MatchingItem>.from(items);
      final rightItems = List<MatchingItem>.from(items);

      // Shuffle the right items to randomize the matching
      rightItems.shuffle(Random());

      emit(
        MatchingGameReady(
          game: game,
          leftItems: leftItems,
          rightItems: rightItems,
        ),
      );
    }
  }

  void _onCheckAllMatches(
    CheckAllMatchesEvent event,
    Emitter<MatchingGameState> emit,
  ) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      final connections = currentState.connections;

      // Check if all items are connected
      final allItemsConnected = currentState.leftItems.every(
        (item) =>
            connections.any((connection) => connection.sourceId == item.id),
      );

      // Check if all connections are correct
      final allConnectionsCorrect = connections.every(
        (connection) => connection.isCorrect,
      );

      // If all items are connected and all connections are correct, the game is completed
      if (allItemsConnected && allConnectionsCorrect) {
        // Play success sound
        add(const PlaySoundEvent('assets/sounds/success.mp3'));

        // Update the state to show all matched
        emit(currentState.copyWith(allMatched: true));

        // After a delay, emit the completed state
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (state is MatchingGameReady) {
            final score = connections.where((c) => c.isCorrect).length;
            emit(
              MatchingGameCompleted(
                game: currentState.game,
                score: score,
                totalPossibleScore: currentState.leftItems.length,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _onPlaySound(
    PlaySoundEvent event,
    Emitter<MatchingGameState> emit,
  ) async {
    try {
      await _audioPlayer.setAsset(event.soundAsset);
      await _audioPlayer.play();
    } catch (e) {
      // Silently fail if sound can't be played
      debugPrint('Failed to play sound: $e');
    }
  }

  void _onRemoveConnection(
    RemoveConnectionEvent event,
    Emitter<MatchingGameState> emit,
  ) {
    if (state is MatchingGameReady) {
      final currentState = state as MatchingGameReady;
      final connections =
          currentState.connections
              .where(
                (connection) =>
                    !(connection.sourceId == event.sourceId &&
                        connection.targetId == event.targetId),
              )
              .toList();

      emit(currentState.copyWith(connections: connections));
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
