/**
 * Join Mind War Screen
 * Allows players to join an existing Mind War by entering the 5-6 character code
 */

import 'package:flutter/material.dart';
import '../services/multiplayer_service.dart';
import '../utils/brand_animations.dart';

class JoinMindWarScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;

  const JoinMindWarScreen({
    Key? key,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  State<JoinMindWarScreen> createState() => _JoinMindWarScreenState();
}

class _JoinMindWarScreenState extends State<JoinMindWarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinMindWar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim().toUpperCase();
      final lobby = await widget.multiplayerService.joinLobbyByCode(code);

      if (!mounted) return;

      // Navigate to lobby screen
      Navigator.of(context).pushReplacementNamed(
        '/lobby',
        arguments: lobby,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Mind War'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 24),
                const Text(
                  'Enter the Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask the Mind War creator to share the 5-6 character code',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Code Input Field
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Mind War Code',
                    hintText: 'e.g., A7K9X',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.vpn_key),
                    counterText: '${_codeController.text.length}/6',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the Mind War code';
                    }
                    if (value.trim().length < 5) {
                      return 'Code must be at least 5 characters';
                    }
                    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.trim())) {
                      return 'Code can only contain letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Join Button
                ElevatedButton(
                  onPressed: _isJoining ? null : _joinMindWar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isJoining
                      ? BrandAnimations.loadingSpinner(size: 20)
                      : const Text(
                          'Join Mind War',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 24),

                // Example codes
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Example codes:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A7K9X  •  2M5RT  •  B8N3P',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
