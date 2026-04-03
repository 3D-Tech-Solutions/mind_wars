/**
 * Game Selection Screen - Feature 3.1.2
 * Allows players to browse and select games from the catalog
 * with filtering by category, player count, and difficulty
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../games/game_catalog.dart';
import '../utils/brand_assets.dart';

class GameSelectionScreen extends StatefulWidget {
  final int playerCount;
  final Function(String gameId)? onGameSelected;
  final bool showPreview;

  const GameSelectionScreen({
    Key? key,
    required this.playerCount,
    this.onGameSelected,
    this.showPreview = true,
  }) : super(key: key);

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  CognitiveCategory? _selectedCategory;
  String _searchQuery = '';

  List<GameTemplate> get _filteredGames {
    var games = GameCatalog.getAllGames();

    // All games support any number of players in a Mind War - no filtering needed

    // Filter by category
    if (_selectedCategory != null) {
      games = games.where((game) => game.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      games = games
          .where((game) =>
              game.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              game.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return games;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _selectedCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Game'),
        backgroundColor: BrandAssets.deepNavy,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BrandAssets.deepNavy,
                  selectedCategory == null
                      ? BrandAssets.surface
                      : BrandAssets.categoryColor(selectedCategory),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                if (selectedCategory != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 88,
                      width: double.infinity,
                      child: Image.asset(
                        BrandAssets.categoryHero(selectedCategory),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (selectedCategory != null) const SizedBox(height: 12),
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search games...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip('All', null),
                      ...GameCatalog.getAllCategories().map(
                        (category) => _buildCategoryChip(
                          GameCatalog.getCategoryInfo(category)['name']!,
                          category,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Player count info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${widget.playerCount} player${widget.playerCount > 1 ? 's' : ''} • ${_filteredGames.length} game${_filteredGames.length != 1 ? 's' : ''} available',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Games grid
          Expanded(
            child: _filteredGames.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = _filteredGames[index];
                      return _buildGameCard(game);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, CognitiveCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? BrandAssets.deepNavy : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    final categoryInfo = GameCatalog.getCategoryInfo(game.category);
    final iconAsset = BrandAssets.gameIcon(game.id);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (widget.showPreview) {
            _showGamePreview(game);
          } else {
            _selectGame(game);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game icon and category
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: _getCategoryColor(game.category),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: iconAsset != null
                    ? Image.asset(
                        iconAsset,
                        width: 68,
                        height: 68,
                      )
                    : Text(
                        game.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
              ),
            ),
            // Game info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          BrandAssets.categoryBadge(game.category),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            categoryInfo['name']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            BrandAssets.categoryBadge(_selectedCategory ?? CognitiveCategory.memory),
            width: 72,
            height: 72,
            color: Colors.grey.shade500,
            colorBlendMode: BlendMode.modulate,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No games found'
                : 'No games available for ${widget.playerCount} players',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Try a different player count',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showGamePreview(GameTemplate game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return GamePreviewSheet(
            game: game,
            scrollController: scrollController,
            onSelect: () {
              Navigator.pop(context);
              _selectGame(game);
            },
          );
        },
      ),
    );
  }

  void _selectGame(GameTemplate game) {
    if (widget.onGameSelected != null) {
      widget.onGameSelected!(game.id);
    } else {
      Navigator.pop(context, game.id);
    }
  }

  Color _getCategoryColor(CognitiveCategory category) {
    return BrandAssets.categoryColor(category).withOpacity(0.16);
  }
}

/// Game Preview Sheet Widget - Feature 3.1.4
class GamePreviewSheet extends StatelessWidget {
  final GameTemplate game;
  final ScrollController scrollController;
  final VoidCallback onSelect;

  const GamePreviewSheet({
    Key? key,
    required this.game,
    required this.scrollController,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryInfo = GameCatalog.getCategoryInfo(game.category);
    final iconAsset = BrandAssets.gameIcon(game.id);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Game icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(game.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: iconAsset != null
                          ? Image.asset(iconAsset, width: 72, height: 72)
                          : Text(
                              game.icon,
                              style: const TextStyle(fontSize: 56),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Game name
                Text(
                  game.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      BrandAssets.categoryBadge(game.category),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryInfo['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Description
                _buildInfoSection(
                  'About',
                  game.description,
                  Icons.info_outline,
                ),
                const SizedBox(height: 16),
                // Rules
                _buildInfoSection(
                  'How to Play',
                  game.rules,
                  Icons.rule,
                ),
                const SizedBox(height: 16),
                // Category description
                _buildInfoSection(
                  'Skills Developed',
                  categoryInfo['description']!,
                  Icons.psychology,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Select button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandAssets.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Select This Game',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return Colors.blue.shade300;
      case CognitiveCategory.logic:
        return Colors.purple.shade300;
      case CognitiveCategory.attention:
        return Colors.orange.shade300;
      case CognitiveCategory.spatial:
        return Colors.green.shade300;
      case CognitiveCategory.language:
        return Colors.pink.shade300;
    }
  }
}
