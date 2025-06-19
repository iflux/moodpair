import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'mood_waiting.dart';

class MoodSelectorScreen extends StatefulWidget {
  final IO.Socket socket;

  MoodSelectorScreen({required this.socket});

  @override
  _MoodSelectorScreenState createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen> {
  final List<Map<String, String>> moods = [
    {'label': 'Heureux', 'emoji': '😊'},
    {'label': 'Triste', 'emoji': '😢'},
    {'label': 'Frustré', 'emoji': '😠'},
    {'label': 'Énergique', 'emoji': '⚡️'},
    {'label': 'Blessé', 'emoji': '💔'},
    {'label': 'Besoin de parler', 'emoji': '💬'},
  ];

  void selectMood(String moodLabel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodWaitingScreen(
          mood: moodLabel,
          socket: widget.socket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        title: Text(
          'MoodPair',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre humeur actuelle',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: moods.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return GestureDetector(
                    onTap: () => selectMood(mood['label']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            mood['emoji']!,
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mood['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
