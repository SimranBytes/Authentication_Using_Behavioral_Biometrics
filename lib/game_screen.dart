import 'dart:async'; // For timers
import 'dart:math'; // For random tile generation
import 'package:flutter/material.dart';
import 'sensor_manager.dart'; // Import SensorManager

class PianoTilesGame extends StatefulWidget {
  final SensorManager sensorManager; // Pass SensorManager for touch data recording

  PianoTilesGame({required this.sensorManager});

  @override
  _PianoTilesGameState createState() => _PianoTilesGameState();
}

class _PianoTilesGameState extends State<PianoTilesGame> {
  final int _rows = 4; // Number of tile rows
  final int _columns = 4; // Number of columns
  List<int> activeTiles = []; // Store active tile positions
  Timer? _gameTimer; // Timer for tile movement
  int score = 0; // Track the player's score

  @override
  void initState() {
    super.initState();
    _startGame(); // Start the game when the widget is initialized
  }

  @override
  void dispose() {
    _gameTimer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  // Start the game with a periodic timer for tile movement
  void _startGame() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _moveTilesDown();
        _generateNewTile();
      });
    });
  }

  // Move tiles down by one row
  void _moveTilesDown() {
    for (int i = 0; i < activeTiles.length; i++) {
      activeTiles[i] += _columns; // Move tile to the next row
    }

    // Remove tiles that move out of bounds (off-screen)
    activeTiles.removeWhere((tile) => tile >= _rows * _columns);
  }

  // Generate a new tile at a random position in the top row
  void _generateNewTile() {
    int newTile = Random().nextInt(_columns); // Random column for the new tile
    activeTiles.insert(0, newTile); // Add new tile to the top row
  }

  // Handle tile taps
  void _handleTileTap(int index) {
    if (activeTiles.contains(index)) {
      setState(() {
        activeTiles.remove(index); // Remove the tile when tapped
        score++; // Increase the score
      });

      // Record the tap using SensorManager
      widget.sensorManager.updateTouchData(Offset(index.toDouble(), 0));
    } else {
      // Game over if the player taps the wrong tile
      _gameTimer?.cancel();
      _showGameOverDialog();
    }
  }

  // Show a game-over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Return to the previous screen
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Piano Tiles'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columns, // Define the number of columns
        ),
        itemCount: _rows * _columns, // Total tiles in the grid
        itemBuilder: (context, index) {
          bool isActive = activeTiles.contains(index); // Check if the tile is active

          return GestureDetector(
            onTap: () => _handleTileTap(index), // Handle tile tap
            child: Container(
              margin: EdgeInsets.all(2),
              color: isActive ? Colors.black : Colors.grey[300], // Active tiles are black
            ),
          );
        },
      ),
    );
  }
}
