/**
 * Debug Panel - Alpha build diagnostic UI
 *
 * [2026-04-03 Feature] Shows backend connectivity status, server URLs,
 * connection errors, and all app logs for alpha testers.
 *
 * Only shown in alpha builds when accessing multiplayer features.
 */

import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/app_logger.dart';
import '../utils/build_config.dart';

class DebugPanel extends StatefulWidget {
  final VoidCallback? onRetry;

  const DebugPanel({super.key, this.onRetry});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel>
    with SingleTickerProviderStateMixin {
  late Future<ConnectivityStatus> _connectivityFuture;
  late TabController _tabController;
  LogLevel? _selectedLogLevel;
  final ScrollController _logsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _testConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  void _testConnectivity() {
    setState(() {
      _connectivityFuture = ConnectivityService.testConnectivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '🔌 Status'),
              Tab(text: '📋 Logs'),
            ],
            indicatorColor: Colors.blue[300],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatusTab(),
                _buildLogsTab(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return FutureBuilder<ConnectivityStatus>(
      future: _connectivityFuture,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                _buildLoadingState()
              else if (snapshot.hasError)
                _buildErrorState(snapshot.error.toString())
              else if (snapshot.hasData)
                _buildStatusContent(snapshot.data!)
              else
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        // Filter buttons
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[850],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLogLevelButton(null, 'All'),
                const SizedBox(width: 8),
                _buildLogLevelButton(LogLevel.debug, 'Debug'),
                const SizedBox(width: 8),
                _buildLogLevelButton(LogLevel.info, 'Info'),
                const SizedBox(width: 8),
                _buildLogLevelButton(LogLevel.warning, '⚠️ Warning'),
                const SizedBox(width: 8),
                _buildLogLevelButton(LogLevel.error, '❌ Error'),
              ],
            ),
          ),
        ),
        // Logs list
        Expanded(
          child: StreamBuilder<LogEntry>(
            stream: AppLogger.logStream,
            builder: (context, snapshot) {
              final logs = _getFilteredLogs();
              return logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: _logsScrollController,
                      reverse: true,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[logs.length - 1 - index];
                        return _buildLogEntry(log);
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  List<LogEntry> _getFilteredLogs() {
    final logs = AppLogger.getLogs();
    if (_selectedLogLevel == null) {
      return logs;
    }
    return logs.where((log) => log.level == _selectedLogLevel).toList();
  }

  Widget _buildLogLevelButton(LogLevel? level, String label) {
    final isSelected = _selectedLogLevel == level;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedLogLevel = selected ? level : null;
        });
      },
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.blue[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[300],
        fontSize: 12,
      ),
    );
  }

  Widget _buildLogEntry(LogEntry log) {
    Color levelColor;
    IconData levelIcon;

    switch (log.level) {
      case LogLevel.debug:
        levelColor = Colors.blue[300]!;
        levelIcon = Icons.bug_report;
        break;
      case LogLevel.info:
        levelColor = Colors.cyan[300]!;
        levelIcon = Icons.info;
        break;
      case LogLevel.warning:
        levelColor = Colors.orange[300]!;
        levelIcon = Icons.warning;
        break;
      case LogLevel.error:
        levelColor = Colors.red[300]!;
        levelIcon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: levelColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(levelIcon, size: 14, color: levelColor),
              const SizedBox(width: 6),
              Text(
                log.formattedTime,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.levelName,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (log.source != null)
                Text(
                  log.source!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontFamily: 'Courier',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            log.message,
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 11,
              fontFamily: 'Courier',
            ),
          ),
          if (log.exception != null) ...[
            const SizedBox(height: 4),
            SelectableText(
              'Exception: ${log.exception}',
              style: TextStyle(
                color: Colors.red[200],
                fontSize: 10,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.bug_report,
          color: Colors.blue[300],
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧪 Alpha Debug Panel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue[300],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Backend Connectivity Check',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Testing connectivity...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 18),
              const SizedBox(width: 8),
              Text(
                'Test Failed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[300],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(ConnectivityStatus status) {
    final allHealthy = status.allHealthy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: allHealthy
                ? Colors.green[900]?.withOpacity(0.3)
                : Colors.red[900]?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: allHealthy ? Colors.green[700]! : Colors.red[700]!,
              width: 1,
            ),
          ),
          child: Text(
            allHealthy ? '✓ All Systems Operational' : '⚠ Connection Issues',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: allHealthy ? Colors.green[300] : Colors.red[300],
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),

        // Server URLs section
        Text(
          'Server Configuration',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildUrlEntry('API', status.apiUrl),
        const SizedBox(height: 8),
        _buildUrlEntry('WebSocket', status.wsUrl),
        const SizedBox(height: 16),

        // Connectivity status
        Text(
          'Connectivity Status',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildStatusItem(
          'API Server',
          status.apiHealthy,
          status.apiError,
        ),
        const SizedBox(height: 8),
        _buildStatusItem(
          'WebSocket Server',
          status.wsConnectable,
          status.wsError,
        ),
        const SizedBox(height: 8),
        _buildStatusItem(
          'Network Available',
          status.networkAvailable,
          null,
        ),
        const SizedBox(height: 16),

        // Build info
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build Info',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              _buildBuildInfoLine('Flavor', BuildConfig.flavor),
              _buildBuildInfoLine('Type', BuildConfig.buildType),
              _buildBuildInfoLine('API URL', BuildConfig.apiBaseUrl),
              _buildBuildInfoLine('WS URL', BuildConfig.wsBaseUrl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlEntry(String label, String url) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[300],
                  fontFamily: 'Courier',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool healthy, String? error) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: healthy
            ? Colors.green[900]?.withOpacity(0.2)
            : Colors.red[900]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: healthy ? Colors.green[700]! : Colors.red[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                healthy ? Icons.check_circle : Icons.cancel,
                color: healthy ? Colors.green[400] : Colors.red[400],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: healthy ? Colors.green[300] : Colors.red[300],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[300],
                    fontSize: 11,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBuildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[300],
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Text(
      'No connectivity data',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
          ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[700]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _testConnectivity();
                if (_tabController.index == 1) {
                  AppLogger.info('Connectivity test initiated');
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_tabController.index == 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  AppLogger.clearLogs();
                  setState(() {});
                },
                icon: const Icon(Icons.delete),
                label: const Text('Clear Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (widget.onRetry != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Convenience function to show the debug panel in a bottom sheet
Future<void> showDebugPanel(
  BuildContext context, {
  VoidCallback? onContinue,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: DebugPanel(onRetry: onContinue),
    ),
  );
}
