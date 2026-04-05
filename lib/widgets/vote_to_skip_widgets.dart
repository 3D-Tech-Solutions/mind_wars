/**
 * Vote-to-Skip UI Components - Phase 2 Social Features
 * Selection Phase skip voting widgets
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Vote-to-skip dialog - Shows when skip vote is initiated
class VoteToSkipDialog extends StatefulWidget {
  final VoteToSkipSession session;
  final String currentUserId;
  final Function(String sessionId) onVoteToSkip;
  final Function(String sessionId) onCancelVote;
  final VoidCallback onDismiss;

  const VoteToSkipDialog({
    Key? key,
    required this.session,
    required this.currentUserId,
    required this.onVoteToSkip,
    required this.onCancelVote,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<VoteToSkipDialog> createState() => _VoteToSkipDialogState();
}

class _VoteToSkipDialogState extends State<VoteToSkipDialog> {
  bool get _hasVoted => widget.session.votes[widget.currentUserId] == true;
  bool get _isPlayerBeingSkipped => widget.currentUserId == widget.session.playerIdToSkip;
  bool get _canVote => !_isPlayerBeingSkipped && widget.session.isActive;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.skip_next, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Skip ${session.playerNameToSkip}\'s Vote?',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              '${session.playerNameToSkip} hasn\'t distributed points for Battle ${session.battleNumber}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Forfeit their 10 points for this Battle?',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Skip rule info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skip Rule: ${session.skipRule.displayName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        if (session.skipRule != SkipRule.timeBased)
                          Text(
                            'Votes Required: ${session.votesRequired}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vote progress
            if (session.skipRule != SkipRule.timeBased) ...[
              Text(
                'Votes: ${session.votesCount}/${session.votesRequired}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: session.votesRequired > 0 ? session.votesCount / session.votesRequired : 0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  session.majorityReached ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Time-based countdown
            if (session.skipRule == SkipRule.timeBased &&
                session.timeLimitHours != null)
              TimeBasedSkipCountdown(
                session: session,
                compact: true,
              ),

            // Voter status list
            if (session.skipRule != SkipRule.timeBased) ...[
              const Text(
                'Vote Status:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildVoterStatusList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Close'),
        ),
        if (_canVote) ...[
          if (_hasVoted)
            OutlinedButton(
              onPressed: () => widget.onCancelVote(session.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel Vote'),
            )
          else
            ElevatedButton(
              onPressed: () => widget.onVoteToSkip(session.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Vote to Skip'),
            ),
        ],
      ],
    );
  }

  Widget _buildVoterStatusList() {
    // This would need player data to show all voters
    // For now, show basic voting status
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildVoterStatusItem(
            widget.session.initiatorName,
            true,
            isInitiator: true,
          ),
          if (_hasVoted && !_isPlayerBeingSkipped)
            _buildVoterStatusItem(
              'You',
              true,
            ),
          if (_isPlayerBeingSkipped)
            _buildVoterStatusItem(
              '${widget.session.playerNameToSkip} (being skipped)',
              false,
              cannotVote: true,
            ),
        ],
      ),
    );
  }

  Widget _buildVoterStatusItem(
    String name,
    bool voted, {
    bool isInitiator = false,
    bool cannotVote = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            voted
                ? Icons.check_circle
                : cannotVote
                    ? Icons.cancel
                    : Icons.hourglass_empty,
            color: voted
                ? Colors.green
                : cannotVote
                    ? Colors.grey
                    : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isInitiator ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isInitiator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'INITIATED',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Vote-to-skip button - Floating action button to initiate skip
class VoteToSkipButton extends StatelessWidget {
  final String playerNameToSkip;
  final bool enabled;
  final VoidCallback onPressed;
  final String? disabledReason;

  const VoteToSkipButton({
    Key? key,
    required this.playerNameToSkip,
    required this.enabled,
    required this.onPressed,
    this.disabledReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enabled
          ? 'Vote to skip $playerNameToSkip\'s Selection vote'
          : disabledReason ?? 'Cannot initiate skip vote',
      child: FloatingActionButton.extended(
        onPressed: enabled ? onPressed : null,
        backgroundColor: enabled ? Colors.orange : Colors.grey,
        icon: const Icon(Icons.skip_next),
        label: Text('Skip $playerNameToSkip'),
      ),
    );
  }
}

/// Skip rule selector - Dropdown for lobby settings
class SkipRuleSelector extends StatelessWidget {
  final SkipRule selectedRule;
  final Function(SkipRule) onRuleChanged;
  final int timeLimitHours;
  final Function(int) onTimeLimitChanged;
  final bool enabled;

  const SkipRuleSelector({
    Key? key,
    required this.selectedRule,
    required this.onRuleChanged,
    required this.timeLimitHours,
    required this.onTimeLimitChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vote-to-Skip Rule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how players can skip AFK voters during Selection Phase',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Skip rule dropdown
        DropdownButtonFormField<SkipRule>(
          value: selectedRule,
          decoration: const InputDecoration(
            labelText: 'Skip Rule',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.rule),
          ),
          items: SkipRule.values.map((rule) {
            return DropdownMenuItem(
              value: rule,
              child: Text(rule.displayName),
            );
          }).toList(),
          onChanged: enabled
              ? (rule) {
                  if (rule != null) {
                    onRuleChanged(rule);
                  }
                }
              : null,
        ),
        const SizedBox(height: 16),

        // Rule explanation
        _buildRuleExplanation(selectedRule),
        const SizedBox(height: 16),

        // Time limit slider (only for time-based rule)
        if (selectedRule == SkipRule.timeBased) ...[
          Text(
            'Auto-Skip Time Limit',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: timeLimitHours.toDouble(),
                  min: 1,
                  max: 72,
                  divisions: 71,
                  label: '$timeLimitHours hours',
                  onChanged: enabled
                      ? (value) => onTimeLimitChanged(value.round())
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 80,
                child: Text(
                  '$timeLimitHours hours',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Text(
            'Players will be automatically skipped after $timeLimitHours hours of inactivity',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRuleExplanation(SkipRule rule) {
    String explanation;
    IconData icon;
    Color color;

    switch (rule) {
      case SkipRule.majority:
        explanation =
            '50% + 1 of active players must vote to skip. Balanced and democratic.';
        icon = Icons.people;
        color = Colors.blue;
        break;
      case SkipRule.unanimous:
        explanation =
            '100% of active players must agree to skip. Strict, ensures everyone agrees.';
        icon = Icons.group;
        color = Colors.purple;
        break;
      case SkipRule.timeBased:
        explanation =
            'Players are automatically skipped after a time limit. No voting needed.';
        icon = Icons.timer;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Time-based skip countdown - Shows remaining time until auto-skip
class TimeBasedSkipCountdown extends StatefulWidget {
  final VoteToSkipSession session;
  final bool compact;

  const TimeBasedSkipCountdown({
    Key? key,
    required this.session,
    this.compact = false,
  }) : super(key: key);

  @override
  State<TimeBasedSkipCountdown> createState() => _TimeBasedSkipCountdownState();
}

class _TimeBasedSkipCountdownState extends State<TimeBasedSkipCountdown> {
  Timer? _timer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeRemaining();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.session.timeRemaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining == null || _timeRemaining!.isNegative) {
      return const SizedBox.shrink();
    }

    final hours = _timeRemaining!.inHours;
    final minutes = _timeRemaining!.inMinutes.remainder(60);
    final seconds = _timeRemaining!.inSeconds.remainder(60);

    // Determine color based on time remaining
    Color color;
    if (hours > 2) {
      color = Colors.green;
    } else if (hours > 0) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Auto-skip in: ${_formatDuration(hours, minutes, seconds)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: color),
                const SizedBox(width: 8),
                const Text(
                  'Auto-Skip Countdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HOURS', color),
                const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'MINS', color),
                const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'SECS', color),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (widget.session.timeLimitHours != null && widget.session.timeLimitHours! > 0)
                  ? 1 - (_timeRemaining!.inSeconds / (widget.session.timeLimitHours! * 3600))
                  : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.session.playerNameToSkip} will be automatically skipped',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int hours, int minutes, int seconds) {
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
