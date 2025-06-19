// ✅ mood_waiting.dart avec animation de cœur pulsant et retour menu

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chat.dart';

class MoodWaitingScreen extends StatefulWidget {
  final String mood;
  final IO.Socket socket;

  MoodWaitingScreen({required this.mood, required this.socket});

  @override
  _MoodWaitingScreenState createState() => _MoodWaitingScreenState();
}

class _MoodWaitingScreenState extends State<MoodWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    widget.socket.emit('join', widget.mood);

    widget.socket.on('matched', (id) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            socket: widget.socket,
            partnerId: id,
            mood: widget.mood,
          ),
        ),
      );
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.socket.off('matched');
    _animationController.dispose();
    super.dispose();
  }

  void cancelSearch() {
    widget.socket.emit('left');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: cancelSearch,
        ),
        centerTitle: true,
        title: Text('MoodPair', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 72),
            ),
            SizedBox(height: 24),
            Text(
              'Connexion en cours...',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              'Recherche d’une personne\nqui ressent la même chose que vous ...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}