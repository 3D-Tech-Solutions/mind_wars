/**
 * Debug Panel - Alpha build diagnostic UI
 *
 * [2026-04-03 Feature] Shows backend connectivity status, server URLs,
 * connection errors, and all app logs for alpha testers.
 *
 * Only shown in alpha builds when accessing multiplayer features.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../services/app_logger.dart';
import '../utils/build_config.dart';
import '../utils/screen_version_registry.dart';
import '../services/network_metrics.dart';
import '../services/multiplayer_service.dart';
import '../services/auth_service.dart';
import '../services/offline_service.dart';
import '../models/models.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
              Tab(text: '🛠️ Tools'),
              Tab(text: '🔄 Sync'),
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
                _buildToolsTab(),
                _buildSyncTab(),
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

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application State Tools',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildToolTile(
            icon: Icons.wifi_off,
            title: 'Force WebSocket Disconnect',
            subtitle: 'Simulates a network drop to test reconnection logic',
            onTap: () {
              try {
                context.read<MultiplayerService>().debugForceDisconnect();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WebSocket manually disconnected')),
                );
              } catch (e) {
                AppLogger.error('Failed to disconnect WS', exception: e);
              }
            },
          ),
          const SizedBox(height: 8),
          _buildToolTile(
            icon: Icons.grid_on,
            title: 'Toggle UI Layout Bounds',
            subtitle: 'Shows wireframes to help debug overflow constraints',
            onTap: () {
              setState(() {
                debugPaintSizeEnabled = !debugPaintSizeEnabled;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildToolTile(
            icon: Icons.delete_forever,
            title: 'Nuke Local State',
            subtitle: 'Logs out and clears local cache (simulates fresh install)',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Nuke Local State?'),
                  content: const Text('This will log you out and clear local session data. The app will return to the login screen.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Nuke'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  AppLogger.warning('🧪 DEBUG: Nuking local state...', source: 'TOOLS');
                  
                  await context.read<AuthService>().logout();
                  // If your OfflineService has a clear/reset method, call it here:
                  // await context.read<OfflineService>().clearDatabase();
                  
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                } catch (e) {
                  AppLogger.error('Failed to nuke state', exception: e);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(icon, color: Colors.blue[300]),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _confirmAndDeleteItem(
    String title,
    String content,
    Future<void> Function() onConfirm,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await onConfirm();
      } catch (e) {
        AppLogger.error('Failed to delete item', exception: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildSyncTab() {
    final offlineService = context.read<OfflineService>();
    
    return FutureBuilder(
      future: Future.wait([
        offlineService.getUnsyncedGames(),
        offlineService.getAllUnsyncedTurns(),
        offlineService.getSyncQueueSize(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: BrandAnimations.loadingSpinner(size: 40),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final unsyncedGames = snapshot.data![0] as List<OfflineGameData>;
        final unsyncedTurns = snapshot.data![1] as List<QueuedTurn>;
        final genericQueueSize = snapshot.data![2] as int;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Offline Payloads',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh Queue',
                    onPressed: () => setState(() {}),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Summary Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSyncStat('Games', unsyncedGames.length.toString()),
                  _buildSyncStat('Turns', unsyncedTurns.length.toString()),
                  _buildSyncStat('API Req', genericQueueSize.toString()),
                ],
              ),
              const SizedBox(height: 24),

              // Force Sync Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final auth = context.read<AuthService>();
                      final userId = auth.currentUser?.id ?? 'unknown';
                      final apiEndpoint = '${BuildConfig.apiBaseUrl}/api';
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting manual sync...')),
                      );
                      
                      await offlineService.syncWithServer(apiEndpoint, userId);
                      await offlineService.syncQueuedTurns(apiEndpoint);
                      
                      if (context.mounted) {
                        setState(() {}); // Refresh view
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sync completed!')),
                        );
                      }
                    } catch (e) {
                      AppLogger.error('Manual sync failed', exception: e);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Force Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (unsyncedGames.isNotEmpty) ...[
                Text('Unsynced Games', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...unsyncedGames.map((g) => _buildPayloadTile(
                  icon: Icons.games,
                  title: '${g.gameType} (${g.score} pts)',
                  subtitle: 'ID: ${g.id}',
                  timestamp: g.timestamp,
                  onDelete: () => _confirmAndDeleteItem(
                    'Delete Unsynced Game?',
                    'Are you sure you want to discard this game payload? This cannot be undone.',
                    () async {
                      await offlineService.deleteOfflineGame(g.id);
                      setState(() {}); // Refresh the tab
                    },
                  ),
                )),
                const SizedBox(height: 16),
              ],

              if (unsyncedTurns.isNotEmpty) ...[
                Text('Unsynced Turns', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...unsyncedTurns.map((t) => _buildPayloadTile(
                  icon: Icons.low_priority,
                  title: 'Turn (Game: ${t.gameId})',
                  subtitle: 'Lobby: ${t.lobbyId} | Retries: ${t.retryCount}',
                  timestamp: t.createdAt,
                  onDelete: () => _confirmAndDeleteItem(
                    'Delete Queued Turn?',
                    'Are you sure you want to discard this turn payload? This cannot be undone.',
                    () async {
                      await offlineService.deleteQueuedTurn(t.id);
                      setState(() {}); // Refresh the tab
                    },
                  ),
                )),
              ],
              
              if (unsyncedGames.isEmpty && unsyncedTurns.isEmpty && genericQueueSize == 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 48, color: Colors.green[400]),
                        const SizedBox(height: 16),
                        Text(
                          'All caught up!\nNo pending offline payloads.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncStat(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildPayloadTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime timestamp,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[300], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red[300],
              padding: const EdgeInsets.only(left: 12),
              constraints: const BoxConstraints(),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Future<void> _exportDebugData() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('=== Mind Wars Debug Export ===');
      buffer.writeln('Date: ${DateTime.now().toIso8601String()}');
      
      final currentRoute = ScreenVersionRegistry().currentRoute.value;
      final screenVersion = ScreenVersionRegistry().getVersion(currentRoute);
      
      buffer.writeln('\n--- Active Screen State ---');
      buffer.writeln('Route: ${currentRoute ?? "Unknown (or modal)"}');
      if (screenVersion != null) {
        buffer.writeln('Name: ${screenVersion.name}');
        buffer.writeln('Version: ${screenVersion.version}');
        buffer.writeln('Updated: ${screenVersion.lastUpdated}');
      } else {
        buffer.writeln('Status: Unregistered Screen');
      }

      buffer.writeln('\n--- Build Info ---');
      buffer.write(BuildConfig.buildInfo);
      
      buffer.writeln('\n--- Network Metrics ---');
      buffer.write(NetworkMetrics().getExportData());

      buffer.writeln('\n--- Logs ---');
      buffer.write(AppLogger.exportLogs());

      final directory = Directory.systemTemp;
      final fileName = 'mind_wars_debug_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(buffer.toString());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: ${file.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        IconButton(
          icon: const Icon(Icons.file_download),
          color: Colors.blue[300],
          tooltip: 'Export Debug Data',
          onPressed: _exportDebugData,
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

        // Current Screen Info
        ValueListenableBuilder<String?>(
          valueListenable: ScreenVersionRegistry().currentRoute,
          builder: (context, currentRoute, _) {
            final screenVersion = ScreenVersionRegistry().getVersion(currentRoute);
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Screen State',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  _buildBuildInfoLine('Route', currentRoute ?? 'Unknown (or modal)'),
                  if (screenVersion != null) ...[
                    _buildBuildInfoLine('Name', screenVersion.name),
                    _buildBuildInfoLine('Version', screenVersion.version),
                    _buildBuildInfoLine('Updated', screenVersion.lastUpdated),
                  ] else
                    _buildBuildInfoLine('Status', 'Unregistered Screen'),
                ],
              ),
            );
          },
        ),

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
              _buildBuildInfoLine('Version', BuildConfig.appVersion),
              _buildBuildInfoLine('Build #', BuildConfig.buildNumber.toString()),
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
