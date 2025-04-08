import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/matching_game.dart';

/// Base class for all matching game events
abstract class MatchingGameEvent extends Equatable {
  const MatchingGameEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the matching game
class InitializeMatchingGameEvent extends MatchingGameEvent {
  final MatchingGame game;

  const InitializeMatchingGameEvent(this.game);

  @override
  List<Object?> get props => [game];
}

/// Event when a drag starts from an item
class DragStartedEvent extends MatchingGameEvent {
  final String itemId;
  final Offset position;

  const DragStartedEvent(this.itemId, this.position);

  @override
  List<Object?> get props => [itemId, position];
}

/// Event when a drag is updated
class DragUpdatedEvent extends MatchingGameEvent {
  final Offset position;

  const DragUpdatedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event when a drag ends on an item
class DragEndedOnItemEvent extends MatchingGameEvent {
  final String targetId;
  final Offset position;

  const DragEndedOnItemEvent(this.targetId, this.position);

  @override
  List<Object?> get props => [targetId, position];
}

/// Event when a drag is canceled
class DragCanceledEvent extends MatchingGameEvent {}

/// Event to reset the game
class ResetGameEvent extends MatchingGameEvent {}

/// Event to check if all matches are correct
class CheckAllMatchesEvent extends MatchingGameEvent {}

/// Event to play a sound
class PlaySoundEvent extends MatchingGameEvent {
  final String soundAsset;

  const PlaySoundEvent(this.soundAsset);

  @override
  List<Object?> get props => [soundAsset];
}

/// Event to remove a connection
class RemoveConnectionEvent extends MatchingGameEvent {
  final String sourceId;
  final String targetId;

  const RemoveConnectionEvent(this.sourceId, this.targetId);

  @override
  List<Object?> get props => [sourceId, targetId];
}
