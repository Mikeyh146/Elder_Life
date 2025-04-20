import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/local_storage.dart';

class PodDetailScreen extends StatefulWidget {
  final String podId;
  final String podName;

  const PodDetailScreen({
    super.key,
    required this.podId,
    required this.podName,
  });

  @override
  State<PodDetailScreen> createState() => _PodDetailScreenState();
}

class _PodDetailScreenState extends State<PodDetailScreen> {
  List<String> selectedColors = [];
  String selectedIcon = 'dragon';
  List<String> availableColors = ['White', 'Blue', 'Black', 'Red', 'Green'];
  List<String> availableIcons = ['dragon', 'sword', 'crown', 'skull', 'tree'];

  List<Player> allPlayers = [];
  List<Player> podPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadAllPlayers();
  }

  Future<void> _loadAllPlayers() async {
    final players = await LocalStorage.getPlayers();
    setState(() {
      allPlayers = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.home, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: selectedColors.length > 1
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: selectedColors.map(_colorFromName).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : BoxDecoration(
                color: selectedColors.isNotEmpty
                    ? _colorFromName(selectedColors.first)
                    : Colors.grey.shade900,
              ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(_iconFromName(selectedIcon), color: Colors.white, size: 32),
                title: _styledText(widget.podName, 24),
                trailing: IconButton(
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                  onPressed: () {
                    // TODO: Pod stats screen
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _showAddPlayerDialog,
                  child: const Text('Add Player'),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: podPlayers.length,
                  itemBuilder: (context, index) {
                    final player = podPlayers[index];
                    return ListTile(
                      title: _styledText(player.name, 18),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            podPlayers.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _styledText('Choose Colors', 16),
                    Wrap(
                      spacing: 8,
                      children: availableColors.map((color) {
                        final isSelected = selectedColors.contains(color);
                        return ChoiceChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (_) => _toggleColor(color),
                          selectedColor: _colorFromName(color),
                          backgroundColor: Colors.white24,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _styledText('Choose Icon', 16),
                    Wrap(
                      spacing: 16,
                      children: availableIcons.map((iconName) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = iconName),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconFromName(iconName),
                                  color: selectedIcon == iconName ? Colors.amber : Colors.white),
                              _styledText(iconName, 12,
                                  color: selectedIcon == iconName ? Colors.amber : Colors.white),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleColor(String color) {
    setState(() {
      if (selectedColors.contains(color)) {
        selectedColors.remove(color);
      } else {
        selectedColors.add(color);
      }
    });
  }

  void _showAddPlayerDialog() {
    final availableToAdd = allPlayers.where((p) => !podPlayers.contains(p)).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a player to add'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableToAdd.length,
              itemBuilder: (context, index) {
                final player = availableToAdd[index];
                return ListTile(
                  title: Text(player.name),
                  onTap: () {
                    setState(() {
                      podPlayers.add(player);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _colorFromName(String color) {
    switch (color) {
      case 'White':
        return Colors.white;
      case 'Blue':
        return Colors.blue;
      case 'Black':
        return Colors.black;
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _iconFromName(String icon) {
    switch (icon) {
      case 'sword':
        return Icons.gavel;
      case 'crown':
        return Icons.emoji_events;
      case 'skull':
        return Icons.warning;
      case 'tree':
        return Icons.forest;
      case 'dragon':
      default:
        return Icons.whatshot;
    }
  }

  Widget _styledText(String text, double fontSize, {Color color = Colors.white}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        shadows: [
          const Shadow(
            offset: Offset(1.5, 1.5),
            blurRadius: 3.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
