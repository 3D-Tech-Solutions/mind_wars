/// Deterministic Game Contract
///
/// Defines the interface for games that support sealed payload gameplay.
/// All games must be able to be reconstructed deterministically from a seed + config.
///
/// This contract ensures:
/// - Same (seed, config) across all players = identical gameplay
/// - Server-side replay for result validation
/// - Fair competitive play with no client-side randomness

abstract class DeterministicGameContract {
  /// Generate the initial game challenge from a sealed payload
  ///
  /// [seed] - Deterministic seed from server (e.g., "abc123")
  /// [config] - Game-specific configuration (difficulty, grid size, etc.)
  ///
  /// Returns a challenge object that can be displayed to the player.
  /// All state needed to validate results must come from seed + config ONLY.
  Map<String, dynamic> generateChallenge({
    required String seed,
    required Map<String, dynamic> config,
  });

  /// Validate submitted metrics against the sealed challenge
  ///
  /// Server calls this to verify the game result is valid.
  /// Client calls this for local offline validation.
  ///
  /// [seed] - The sealed seed used to generate the challenge
  /// [config] - The sealed config used to generate the challenge
  /// [metrics] - Player's submitted metrics (accuracy, timeMs, mistakes)
  ///
  /// Returns true if metrics are plausible and valid.
  /// Rejects impossible/cheated metrics.
  bool validateMetrics({
    required String seed,
    required Map<String, dynamic> config,
    required Map<String, dynamic> metrics,
  });

  /// Get the schema version for this game engine
  ///
  /// Ensures client and server are compatible.
  /// If versions don't match, the game challenge is re-generated.
  int get schemaVersion;

  /// Get the game's unique identifier
  ///
  /// Used to match sealed payloads with game engines.
  /// Example: "memory_matrix", "rotation_master", "path_finder"
  String get gameId;
}

/// Sealed Payload Structure
///
/// Sent from server to client for a specific game
class SealedPayload {
  /// The unique game ID (e.g., "memory_matrix")
  final String gameId;

  /// Deterministic seed for RNG (e.g., "r7X9kQ")
  /// All randomness must derive from this seed
  final String seed;

  /// Game-specific configuration
  /// Example: {"difficulty": 3, "gridSize": 5}
  final Map<String, dynamic> config;

  /// HMAC or Ed25519 signature for verification
  /// Prevents client from modifying seed/config
  final String signature;

  /// When this payload expires (ISO 8601 format)
  final String expiresAt;

  /// Server schema version for validation
  final int schemaVersion;

  const SealedPayload({
    required this.gameId,
    required this.seed,
    required this.config,
    required this.signature,
    required this.expiresAt,
    required this.schemaVersion,
  });

  /// Create from JSON response
  factory SealedPayload.fromJson(Map<String, dynamic> json) {
    return SealedPayload(
      gameId: json['gameId'] as String,
      seed: json['seed'] as String,
      config: json['config'] as Map<String, dynamic>,
      signature: json['signature'] as String,
      expiresAt: json['expiresAt'] as String,
      schemaVersion: json['schemaVersion'] as int? ?? 1,
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'seed': seed,
    'config': config,
    'signature': signature,
    'expiresAt': expiresAt,
    'schemaVersion': schemaVersion,
  };

  /// Check if payload has expired
  bool get isExpired {
    try {
      final expiry = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true; // Treat parse error as expired
    }
  }
}

/// Game Result Metrics
///
/// What the client submits after playing a sealed game
class GameMetrics {
  /// Unique ID for this game instance (client-generated UUID)
  final String clientGameId;

  /// The sealed seed used for this game
  final String seed;

  /// Game-specific metrics
  /// Standard fields: accuracy (0.0-1.0), timeMs (int), mistakes (int)
  /// Game-specific fields can be added as needed
  final Map<String, dynamic> metrics;

  /// Hash of game events for additional validation (optional)
  /// Computed by client: SHA256(serialized events)
  final String? eventsHash;

  const GameMetrics({
    required this.clientGameId,
    required this.seed,
    required this.metrics,
    this.eventsHash,
  });

  /// Create from JSON
  factory GameMetrics.fromJson(Map<String, dynamic> json) {
    return GameMetrics(
      clientGameId: json['clientGameId'] as String,
      seed: json['seed'] as String,
      metrics: json['metrics'] as Map<String, dynamic>,
      eventsHash: json['eventsHash'] as String?,
    );
  }

  /// Convert to JSON for submission
  Map<String, dynamic> toJson() => {
    'clientGameId': clientGameId,
    'seed': seed,
    'metrics': metrics,
    if (eventsHash != null) 'eventsHash': eventsHash,
  };
}
