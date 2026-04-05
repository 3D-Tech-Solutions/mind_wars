/**
 * Lobby Settings Screen
 * Allows host to configure lobby settings such as max players, rounds, etc.
 * Includes vote-to-skip rule configuration
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/vote_to_skip_widgets.dart';

class LobbySettingsScreen extends StatefulWidget {
  final GameLobby lobby;
  final Function(
    int maxPlayers,
    int totalRounds,
    int votingPoints,
    SkipRule skipRule,
    int skipTimeLimitHours,
  )? onSave;

  const LobbySettingsScreen({
    Key? key,
    required this.lobby,
    this.onSave,
  }) : super(key: key);

  @override
  State<LobbySettingsScreen> createState() => _LobbySettingsScreenState();
}

class _LobbySettingsScreenState extends State<LobbySettingsScreen> {
  late int _maxPlayers;
  late int _totalRounds;
  late int _votingPoints;
  late SkipRule _skipRule;
  late int _skipTimeLimitHours;

  @override
  void initState() {
    super.initState();
    _maxPlayers = widget.lobby.maxPlayers;
    _totalRounds = widget.lobby.numberOfRounds;
    _votingPoints = widget.lobby.votingPointsPerPlayer;
    _skipRule = widget.lobby.skipRule;
    _skipTimeLimitHours = widget.lobby.skipTimeLimitHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingCard(
            title: 'Max Players',
            subtitle: 'Maximum number of players allowed in this lobby',
            child: Slider(
              value: _maxPlayers.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: _maxPlayers.toString(),
              onChanged: (value) {
                setState(() {
                  _maxPlayers = value.round();
                });
              },
            ),
            trailing: Text(
              _maxPlayers.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Total Rounds',
            subtitle: 'Number of rounds to play before lobby closes',
            child: Slider(
              value: _totalRounds.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _totalRounds.toString(),
              onChanged: (value) {
                setState(() {
                  _totalRounds = value.round();
                });
              },
            ),
            trailing: Text(
              _totalRounds.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Voting Points',
            subtitle: 'Points each player gets to vote on games',
            child: Slider(
              value: _votingPoints.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              label: _votingPoints.toString(),
              onChanged: (value) {
                setState(() {
                  _votingPoints = value.round();
                });
              },
            ),
            trailing: Text(
              _votingPoints.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),
          // Vote-to-Skip Rule Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.skip_next, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Vote-to-Skip Rule',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure how AFK players are skipped during Selection Phase',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SkipRuleSelector(
                    selectedRule: _skipRule,
                    onRuleChanged: (rule) {
                      setState(() {
                        _skipRule = rule;
                      });
                    },
                    timeLimitHours: _skipTimeLimitHours,
                    onTimeLimitChanged: (hours) {
                      setState(() {
                        _skipTimeLimitHours = hours;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lobby Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Lobby Code', widget.lobby.lobbyCode ?? 'N/A'),
                  _buildInfoRow('Host', widget.lobby.hostId),
                  _buildInfoRow(
                    'Current Players',
                    '${widget.lobby.players.length}/${widget.lobby.maxPlayers}',
                  ),
                  _buildInfoRow('Status', widget.lobby.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Validate that maxPlayers is not less than current player count
    if (_maxPlayers < widget.lobby.players.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Max players cannot be less than current player count (${widget.lobby.players.length})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the onSave callback if provided
    widget.onSave?.call(
      _maxPlayers,
      _totalRounds,
      _votingPoints,
      _skipRule,
      _skipTimeLimitHours,
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }
}
